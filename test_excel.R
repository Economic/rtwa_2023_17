library(tidyverse)
library(openxlsx2)


# a small number of workers are being marked as directly affected 
# but then see no wage change. maybe related to subminimum wage issues
# mark these obs as not directly affected
# create new direct{step} column
repair_direct_step <- function(data, step) {
  direct_var_name <- paste0("direct", step)
  dwage_var_name <- paste0("d_wage", step)
  
  data %>% 
    mutate("{direct_var_name}" := if_else(
      .data[[direct_var_name]] == 1 & is.na(.data[[dwage_var_name]]),
      0,
      .data[[direct_var_name]]
    )) %>% 
    select(all_of(direct_var_name))
}

# modify all direct{step} columns in original data
repair_directly_affected <- function(data) {
  direct_colnames <- data %>% 
    select(matches("^direct")) %>% 
    colnames() 
  
  steps <- length(direct_colnames)
  
  repaired_columns <- map(1:steps, ~ repair_direct_step(data, .x)) %>% 
    list_cbind()
  
  data %>% 
    select(-all_of(direct_colnames)) %>% 
    bind_cols(repaired_columns)
}

# some indirectly affected receive very small wage increase
# mark those with wage increase < 5 cents as not indirectly affected
# create new direct{step} column
repair_indirect_step <- function(data, step) {
  indirect_var_name <- paste0("indirect", step)
  dwage_var_name <- paste0("d_wage", step)
  
  data %>% 
    mutate("{indirect_var_name}" := if_else(
      .data[[indirect_var_name]] == 1 & .data[[dwage_var_name]] < 0.05,
      0,
      .data[[indirect_var_name]]
    )) %>% 
    select(all_of(indirect_var_name))
}

# modify all direct{step} columns in original data
repair_indirectly_affected <- function(data) {
  indirect_colnames <- data %>% 
    select(matches("^indirect")) %>% 
    colnames() 
  
  steps <- length(indirect_colnames)
  
  repaired_columns <- map(1:steps, ~ repair_indirect_step(data, .x)) %>% 
    list_cbind()
  
  data %>% 
    select(-all_of(indirect_colnames)) %>% 
    bind_cols(repaired_columns)
}

results <- tar_read(prep_acs_data) %>%
  mutate(all = haven::labelled(1, c("All workers" = 1))) %>% 
  # mark as not directly affected those with no wage change
  repair_directly_affected() %>% 
  # mark as not indirectly affected those with small wage change
  repair_indirectly_affected()

state_codes <- tigris::fips_codes %>% 
  distinct(state, state_code, state_name) %>% 
  transmute(
    state_abb = state,
    state_fips = as.numeric(state_code),
    state_name
  ) %>% 
  filter(state_fips <= 56) %>% 
  as_tibble()


cpi_deflator <- 305.535 / 344.789

# Group	Total estimated workforce (thousands)	
# Directly affected (thousands)	
# Share of group directly affected	
# Indirectly affected (thousands)	
# Share of group indirectly affected	
# Total affected (thousands)	
# Share of group who are affected	
# Group’s share of total affected	
# Change in avg. annual earnings (year-round workers, 2021$)

groups_labels <- tribble(
  ~group_var, ~group_label,
  "all", "All workers",
  "female", "Gender",
  "teens", "Age group",
  "agec", "",
  "racec", "Race/ethnicity",
  "poc", "",
  "childc", "Family status",
  "edc", "Education",
  "faminc", "Family Income",
  "povstat", "Family income-to-poverty ratio",
  "hourc", "Work hours",
  "indc", "Industry",
  "tipc", "Tipped occupations",
  "sectc", "Sector"
)

summary_affected <- function(data, group_var, group_label) {
  grouped_data <- data %>% 
    mutate(
      weight = perwt6,
      d_affected = direct6 == 1,
      i_affected = indirect6 == 1,
      affected = d_affected == 1 | i_affected == 1,
      ann_wage_change = d_annual_inc6,
      cf_annual_wage = cf_annual_inc6,
    ) %>% 
    group_by(group = .data[[group_var]]) 
  
  data_affected_summary <- grouped_data %>% 
    filter(affected == 1) %>% 
    summarize(
      wage_change_avg_ann = weighted.mean(ann_wage_change, w = weight) * cpi_deflator,
      wage_change_total_ann = sum(ann_wage_change * weight) * cpi_deflator,
      wage_cf_total_ann = sum(cf_annual_wage * weight) * cpi_deflator
    )
    
  grouped_data %>%   
    summarize(
      total_workforce = sum(weight),
      total_d_affected = sum(d_affected * weight),
      share_d_affected = weighted.mean(d_affected, w = weight),
      total_i_affected = sum(i_affected * weight),
      share_i_affected = weighted.mean(i_affected, w = weight),
      total_affected = sum(affected * weight),
      share_affected = weighted.mean(affected, w = weight),
      n_workforce = n(),
      n_affected = sum(affected)
    ) %>% 
    full_join(data_affected_summary, by = "group") %>% 
    mutate(
      share_group_affected = total_affected / sum(total_affected),
      wage_change_affected_pct = wage_change_total_ann / wage_cf_total_ann,
      group_var := {{group_var}},
      group_val_str= as.character(haven::as_factor(group)),
      group_val_num = as.numeric(group),
    ) %>% 
    select(-group, -wage_cf_total_ann) %>% 
    add_row(.before = 1) %>% 
    mutate(group := if_else(is.na(group_val_str), group_label, group_val_str)) %>% 
    relocate(group_var, group_val_str, group_val_num, group) 
}

misc_cleanup <- function(data) {
  data %>% 
    # drop missing faminc, probably due to group quarters
    mutate(missing = group_var == "faminc" & is.na(group_val_str)) %>% 
    filter(!missing | is.na(missing)) %>% 
    select(-missing) %>% 
    # drop additional blank "All workers" row
    filter(!(group == "All workers" & is.na(total_workforce)))
}

us_results <- groups_labels %>% 
  pmap(~ summary_affected(results, ..1, ..2)) %>% 
  list_rbind() %>% 
  mutate(state_fips = 0, state_abb = "US", state_name = "United States")

# state tables
state_results <- results %>% 
  rename(state_fips = statefips) %>% 
  nest_by(state_fips) %>% 
  mutate(group_analysis = list(
    pmap(groups_labels, ~ summary_affected(data, ..1, ..2))
  )) %>% 
  reframe(list_rbind(group_analysis)) %>% 
  full_join(state_codes, by = "state_fips") %>% 
  bind_rows(us_results) %>% 
  misc_cleanup %>% 
  select(-matches("^group_")) %>% 
  mutate(across(matches("^total_"), ~ round(.x / 1000) * 1000)) %>% 
  mutate(across(matches("^total_"), ~ scales::label_comma(accuracy = 1)(.x))) %>% 
  mutate(across(matches("^share_"), ~ scales::label_percent(accuracy = 0.1)(.x))) %>% 
  mutate(across(matches("^total_|^share"), ~ if_else(n_workforce < 1500, "*", .x))) %>% 
  mutate(wage_change_total_ann = wage_change_total_ann / 10^6) %>% 
  mutate(across(
    wage_change_total_ann|wage_change_avg_ann,
    ~ scales::label_comma(accuracy = 1)(.x)
  )) %>% 
  mutate(wage_change_affected_pct = 
           scales::label_percent(accuracy = 0.1)(wage_change_affected_pct)
  ) %>% 
  mutate(across(matches("^wage_change"), ~ if_else(n_affected < 1500, "*", .x))) %>% 
  select(-n_affected, -n_workforce) %>% 
  mutate(across(where(is.character), ~ replace_na(.x, ""))) %>% 
  rename(
    "Group" = group,
    "Total workforce" = total_workforce,
    "Directly affected" = total_d_affected,
    "Share directly affected" = share_d_affected,
    "Indirectly affected" = total_i_affected,
    "Share indirectly affected" = share_i_affected,
    "Total affected" = total_affected,
    "Share of group who are affected" = share_affected,
    "Group's share of total affected" = share_group_affected
  )

add_state_worksheet <- function(workbook, state_abbreviation, data) {
  state_data <- data %>% 
    filter(state_abb == state_abbreviation) %>% 
    select(
      -matches("^state_"), 
      -wage_change_total_ann,
      -wage_change_avg_ann,
      -wage_change_affected_pct
    )
  
  if (state_abbreviation == "US") state_name <- "United States"
  else {
    state_name <- tigris::fips_codes %>% 
      filter(state == state_abbreviation) %>% 
      filter(row_number() == 1) %>% 
      pull(state_name)
  }
  
  sheet_table_title <- paste(
    "Demographic characteristics of", 
    state_name, 
    "workers who would benefit if the federal minimum wage were raised to $17 by 2028"
  )
  
  fill_color <- "ffebf2fa"
  workbook <- workbook %>%
    wb_add_worksheet(state_name, gridLines = FALSE) %>%
    wb_add_data(x = state_data, startRow = 2) %>%
    wb_merge_cells(rows = 1, cols = 1:9) %>%
    wb_add_data(x = sheet_table_title, startRow = 1) %>%
    wb_set_col_widths(cols = 2:9, widths = 15) %>%
    wb_set_col_widths(cols = 1, widths = 45) %>% 
    wb_set_row_heights(rows = 1, heights = 30) %>% 
    wb_set_row_heights(rows = 2, heights = 45) %>% 
    wb_add_cell_style(dims = "A1", horizontal = "center") %>%
    wb_add_cell_style(dims = "B2:I2", wrapText = "1", horizontal = "center") %>% 
    wb_add_cell_style(dims = "B3:I75", horizontal = "right") %>% 
    wb_add_cell_style(dims = "D3:D75", horizontal = "center") %>% 
    wb_add_cell_style(dims = "F3:F75", horizontal = "center") %>% 
    wb_add_cell_style(dims = "H3:H75", horizontal = "center") %>% 
    wb_add_cell_style(dims = "I3:I75", horizontal = "center") %>% 
    wb_add_font(dims = "A1", size = "15") %>% 
    wb_add_font(dims = "A2:I2", bold = TRUE) %>%
    wb_add_font(dims = "A3", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A4", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A7", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A15", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A24", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A29", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A35", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A42", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A47", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A51", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A69", bold = TRUE, italic = TRUE) %>% 
    wb_add_font(dims = "A72", bold = TRUE, italic = TRUE) %>% 
    wb_add_border(
      dims = "B2:B75", 
      bottom_border = NULL,
      top_border = NULL,
      left_border = "thin",
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "G3:G75", 
      bottom_border = NULL,
      top_border = NULL,
      left_border = "thin",
      right_border = "thin"
    ) %>% 
    wb_add_border(
      dims = "A2:I2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = NULL,
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "B2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = "thin",
      right_border = NULL
    ) 
  
  # fill style
  for (i in seq(4, 74, 2)) {
    dim_range <- paste0("A", i, ":I", i)
    workbook <- workbook %>% 
      wb_add_fill(dims = dim_range, color = wb_color(hex = fill_color))
  }
  
  workbook
    
}

add_intro_worksheet <- function(workbook) {
  workbook %>% 
    wb_add_worksheet("README") %>%
    wb_add_data(x = "README") %>% 
    wb_add_data(x = "something", startRow = 3) %>% 
    wb_add_data(x = "something else", startCol = 4) 
}

add_state_summary_worksheet <- function(workbook, data) {
  
  state_summary_data <- data %>% 
    filter(Group == "All workers") %>% 
    mutate(order = if_else(state_name == "United States", 0, 1)) %>% 
    arrange(order, state_name) %>% 
    select(
      -order, 
      -state_abb, 
      -state_fips, 
      -Group, 
      -`Group's share of total affected`
    ) %>% 
    select(State = state_name, everything()) %>% 
    mutate(State = if_else(State == "United States", "U.S. Total", State)) %>% 
    rename(
      "Total annual wage change (2023$, millions)" = wage_change_total_ann,
      "Average annual wage increase of affected workers (2023$)" = wage_change_avg_ann,
      "Percent change in average annual wages of affected workers" = wage_change_affected_pct
    )
  
  sheet_table_title <- "Summary of effects in 2028 of increasing the minimum wage to $17 by 2028, by state"
  
  fill_color <- "ffebf2fa"
  
  workbook <- workbook %>% 
    wb_add_worksheet("State summary", gridLines = FALSE) %>%
    wb_add_data(x = state_summary_data, startRow = 2) %>%
    wb_merge_cells(rows = 1, cols = 1:11) %>%
    wb_add_data(x = sheet_table_title, startRow = 1) %>%
    wb_set_col_widths(cols = 2:11, widths = 15) %>%
    wb_set_col_widths(cols = 1, widths = 45) %>% 
    wb_set_row_heights(rows = 1, heights = 30) %>% 
    wb_set_row_heights(rows = 2, heights = 60) %>% 
    wb_add_cell_style(dims = "A1", horizontal = "center") %>%
    wb_add_cell_style(dims = "A2:A54", horizontal = "left") %>%
    wb_add_cell_style(dims = "B2:K2", wrapText = "1", horizontal = "center") %>% 
    wb_add_cell_style(dims = "B3:K54", horizontal = "center") %>% 
    wb_add_font(dims = "A1", size = "15") %>% 
    wb_add_font(dims = "A2:K2", bold = TRUE) %>%
    wb_add_border(
      dims = "B2:B54", 
      bottom_border = NULL,
      top_border = NULL,
      left_border = "thin",
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "A2:K2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = NULL,
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "B2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = "thin",
      right_border = NULL
    ) 
  
  # fill style
  for (i in seq(4, 54, 2)) {
    dim_range <- paste0("A", i, ":K", i)
    workbook <- workbook %>% 
      wb_add_fill(dims = dim_range, color = wb_color(hex = fill_color))
  }
  
  workbook
}

wb <- wb_workbook() %>% 
  add_intro_worksheet() %>% 
  add_state_summary_worksheet(state_results)

state_names <- state_results %>% 
  pull(state_abb) %>% 
  unique() %>% 
  sort()
for (i in c("CA", "DC", "MS", "NY", "US")) {
  wb <- wb %>% 
    add_state_worksheet(i, state_results)
}


wb_save(wb, "rtwa_17_2028_state_tables.xlsx")
# workbook for states
# intro
# state summary table
# state-specific tables (all states with available info, plus US)

# congressional district workbook
# intro
# single summary CD table

# # add some dummy data
# set.seed(123)
# mat <- matrix(rnorm(28 * 28, mean = 44444, sd = 555), ncol = 28)
# colnames(mat) <- make.names(seq_len(ncol(mat)))
# border_col <- wb_color(theme = 1)
# border_sty <- "thin"
# 
# # prepare workbook with data and formated first row
# wb <- wb_workbook() %>%
#   wb_add_worksheet("test") %>%
#   wb_add_data(x = mat) %>%
#   wb_add_border(dims = "A1:AB1",
#                 top_color = border_col, top_border = border_sty,
#                 bottom_color = border_col, bottom_border = border_sty,
#                 left_color = border_col, left_border = border_sty,
#                 right_color = border_col, right_border = border_sty,
#                 inner_hcolor = border_col, inner_hgrid = border_sty
#   ) %>%
#   wb_add_fill(dims = "A1:AB1", color = wb_color(hex = "FF334E6F")) %>%
#   wb_add_font(dims = "A1:AB1", name = "Arial", bold = TRUE, color = wb_color(hex = "FFFFFFFF"), size = 20) %>%
#   wb_add_cell_style(dims = "A1:AB1", horizontal = "center", textRotation = 45)
# 
# # create various number formats
# x <- c(
#   0, 1, 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
#   37, 38, 39, 40, 45, 46, 47, 48, 49
# )
# 
# # apply the styles
# for (i in seq_along(x)) {
#   cell <- sprintf("%s2:%s29", int2col(i), int2col(i))
#   wb <- wb %>% wb_add_numfmt(dims = cell, numfmt = x[i])
# }
# 
# # wb$open()