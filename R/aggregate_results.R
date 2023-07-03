create_state_results <- function(microdata) {
  state_codes <- tigris::fips_codes %>% 
    distinct(state, state_code, state_name) %>% 
    transmute(
      state_abb = state,
      state_fips = as.numeric(state_code),
      state_name
    ) %>% 
    filter(state_fips <= 56) %>% 
    as_tibble()
  
  groups_labels <- c(
    "all" = "All workers",
    "female" = "Gender",
    "teens" = "Age group",
    "agec" = "",
    "racec" = "Race/ethnicity",
    "poc" = "",
    "childc" = "Family status",
    "edc" = "Education",
    "faminc" = "Family Income",
    "povstat" = "Family income-to-poverty ratio",
    "hourc" = "Work hours",
    "indc" = "Industry",
    "tipc" = "Tipped occupations",
    "sectc" = "Sector"
  )
    
  
  us_results <- groups_labels %>% 
    imap(~ summary_affected(microdata, .y, .x)) %>% 
    list_rbind() %>% 
    mutate(state_fips = 0, state_abb = "US", state_name = "United States")
  
  # state tables
  state_results <- microdata %>%
    rename(state_fips = statefips) %>%
    nest_by(state_fips) %>%
    mutate(group_analysis = list(
      imap(groups_labels, ~ summary_affected(data, .y, .x))
    )) %>%
    reframe(list_rbind(group_analysis)) %>%
    full_join(state_codes, by = "state_fips") %>%
    bind_rows(us_results) %>%
    misc_cleanup %>%
    select(-matches("^group_")) %>%
    # suppress affected counts/shares values if
    # * estimated affected total less than 1500
    # * estimated affected share less 0.5%
    # * workforce sample size less than 1500
    # suppress wage changes if affected sample size less than 1000
    mutate(across(matches("^total"), ~ if_else(.x < 1500, NA, .x))) %>%
    mutate(across(matches("^share"), ~ if_else(.x < 0.005, NA, .x))) %>%
    mutate(across(
      matches("d_affected"),
      ~ if_else(is.na(total_d_affected) | is.na(share_d_affected), NA, .x)
    )) %>%
    mutate(across(
      matches("i_affected"),
      ~ if_else(is.na(total_i_affected) | is.na(share_i_affected), NA, .x)
    )) %>%
    mutate(across(
      all_of(c("total_affected", "share_affected")),
      ~ if_else(is.na(total_affected) | is.na(share_affected), NA, .x)
    )) %>%
    mutate(across(matches("^total_"), ~ round(.x / 1000) * 1000)) %>%
    mutate(across(
      matches("^total_"),
      ~ scales::label_comma(accuracy = 1)(.x)
    )) %>%
    mutate(across(
      matches("^share_"),
      ~ scales::label_percent(accuracy = 0.1)(.x)
    )) %>%
    mutate(across(
      matches("^total_|^share_"),
      ~ if_else(is.na(.x) & !is.na(n_workforce), "*", .x)
    )) %>%
    mutate(across(
      matches("^total_|^share_"),
      ~ if_else(n_workforce < 1000, "*", .x)
    )) %>%
    mutate(wage_change_total_ann = wage_change_total_ann / 10^6) %>%
    mutate(across(
      wage_change_total_ann|wage_change_avg_ann,
      ~ scales::label_comma(accuracy = 1)(.x)
    )) %>%
    mutate(wage_change_affected_pct =
             scales::label_percent(accuracy = 0.1)(wage_change_affected_pct)
    ) %>%
    mutate(across(
      matches("^wage_change"),
      ~ if_else(n_affected < 1000, "*", .x)
    )) %>%
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
}


summary_affected <- function(data, group_var, group_label) {
  
  cpi_deflator <- 305.535 / 344.789
  
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

