create_cd_spreadsheet <- function(data, filename) {
  # add notes
  source <- paste(
    fmt_txt("Source: ", bold = TRUE),
    fmt_txt("Economic Policy Institute Minimum Wage Simulation Model; see Technical Methodology by Cooper, Mokhiber, and Zipperer (2019).")
  )
  
  notes <- paste(
    fmt_txt("Notes: ", bold = TRUE),
    fmt_txt("Values reflect the population estimated to be affected by the proposed change in the federal minimum wage. Wage changes resulting from scheduled state and local minimum wage laws are accounted for by EPI’s Minimum Wage Simulation Model. Totals may not sum due to rounding. Shares calculated from unrounded values. Affected workers include both directly affected workers (those who will see their wages rise as the new minimum wage rate will exceed their projected hourly pay) and indirectly affected workers (who will otherwise have a wage rate between the new minimum wage and 115% of the new minimum). Values marked * cannot be displayed because of sample size restrictions.")
  )
  
  wb <- wb_workbook() %>% 
    add_cd_intro_worksheet() %>% 
    add_cd_summary_worksheet(data, notes, source)
  
   wb_save(wb, filename)
  
  filename
}


add_cd_summary_worksheet <- function(workbook, data, notes, source) {
  
  cd_summary_data <- data 
  
  sheet_table_title <- "Summary of effects in 2028 of increasing the minimum wage to $17 by 2028, by 118th Congressional District"
  
  fill_color <- "ffebf2fa"
  
  workbook <- workbook %>% 
    wb_add_worksheet("Results", gridLines = FALSE) %>%
    wb_add_data(x = cd_summary_data, start_row = 2) %>%
    wb_merge_cells(rows = 1, cols = 1:7) %>%
    wb_add_data(x = sheet_table_title, start_row = 1) %>%
    wb_set_col_widths(cols = 1, widths = 20) %>% 
    wb_set_col_widths(cols = 2, widths = 15) %>% 
    wb_set_col_widths(cols = 3:7, widths = 20) %>%
    wb_set_row_heights(rows = 1, heights = 30) %>% 
    wb_set_row_heights(rows = 2, heights = 60) %>% 
    wb_add_cell_style(dims = "A1", horizontal = "center") %>%
    wb_add_cell_style(dims = "A2:A439", horizontal = "left") %>%
    wb_add_cell_style(dims = "B2:G2", wrapText = "1", horizontal = "center") %>% 
    wb_add_cell_style(dims = "B3:G439", horizontal = "center") %>% 
    wb_add_font(dims = "A1", size = "15") %>% 
    wb_add_font(dims = "A2:G2", bold = TRUE) %>%
    wb_add_border(
      dims = "C2:C439", 
      bottom_border = NULL,
      top_border = NULL,
      left_border = "thin",
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "A2:G2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = NULL,
      right_border = NULL
    ) %>% 
    wb_add_border(
      dims = "C2", 
      bottom_border = "thick",
      top_border = "medium",
      left_border = "thin",
      right_border = NULL
    ) 
  
  # fill style
  for (i in seq(4, 438, 2)) {
    dim_range <- paste0("A", i, ":G", i)
    workbook <- workbook %>% 
      wb_add_fill(dims = dim_range, color = wb_color(hex = fill_color))
  }
  
  workbook <- workbook %>% 
    wb_merge_cells(rows = 440, cols = 1:7) %>%
    wb_add_data(x = notes, start_row = 440) %>% 
    wb_add_cell_style(dims = "A440", wrapText = "1") %>% 
    wb_set_row_heights(rows = 440, heights = 70) %>% 
    wb_merge_cells(rows = 441, cols = 1:7) %>% 
    wb_add_cell_style(dims = "A441", wrapText = "1") %>% 
    wb_add_data(x = source, start_row = 441)
  
  workbook
}

add_cd_intro_worksheet <- function(workbook) {
  workbook %>% 
    wb_add_worksheet("README") %>%
    wb_add_data(x = "118th Congressional District-specific estimates of the Raise the Wage Act of 2023", start_row = 1) %>% 
    wb_add_data(x = "Economic Policy Institute, August 2023", start_row = 2) %>% 
    wb_add_data(x = "This spreadsheet contains Congressional District-specific estimates of the effects of the Raise the Wage Act of 2023, as estimated by the Economic Policy Institute Minimum Wage Simulation Model.", start_row = 4) %>% 
    wb_add_data(x = "Estimates for some areas are unavailable because of the small number of workers affected by the policy in these states.", start_row = 6) %>% 
    wb_add_data(x = "CITATIONS", start_row = 8) %>% 
    wb_add_data(x = "Please cite the estimates in this spreadsheet as \"Estimated effects of Raise the Wage Act of 2023,\" Economic Policy Institute Minimum Wage Simulation Model, August 2023.", start_row = 9) %>% 
    wb_add_data(x = "ASSUMPTIONS", start_row = 11) %>% 
    wb_add_data(x = "The estimates are for the year 2028, when the policy's regular minimum wage is $17 and the tipped minimum wage is $15.", start_row = 12) %>% 
    wb_add_data(x = "The underlying wage distribution is based on the 2022 Current Population Survey.", start_row = 13) %>%
    wb_add_data(x = "The underlying geographic data is based on the 2015-2019 American Community Survey (ACS), reweighted to match 2019 ACS-based gender-specific employment counts of 118th Congressional Districts.", start_row = 14) %>%
    wb_add_data(x = "The simulation assumes nominal wage growth will be at a 5.0% annual rate between 2022 and 2023, and at a annual rate of 0.5% plus projected CPI growth in subsequent years.", start_row = 15) %>% 
    wb_add_data(x = "The simulation accounts for estimated effects of projected state and local minimum wages between 2023 and 2028.", start_row = 16) %>%
    wb_add_data(x = "DOCUMENTATION", start_row = 18) %>% 
    wb_add_data(x = "To read more about the EPI Minimum Wage Simulation Model, see", start_row = 19) %>% 
    wb_add_data(x = "* the description in Cooper, Mokhiber, Zipperer (2019): https://www.epi.org/publication/minimum-wage-simulation-model-technical-methodology/", start_row = 20) %>% 
    wb_add_data(x = "* a Stata implementation of the simulation model: https://github.com/Economic/min_wage_sim", start_row = 21) %>% 
    wb_add_data(x = "* the code used to produce these estimates: https://github.com/Economic/rtwa_2023_17", start_row = 22) %>% 
    wb_add_font(dims = "A1", size = "15", bold = TRUE) %>% 
    wb_set_col_widths(cols = 1, widths = 175) %>% 
    wb_add_font(dims = "A8", bold = TRUE) %>%
    wb_add_font(dims = "A11", bold = TRUE) %>%
    wb_add_font(dims = "A18", bold = TRUE) 
}