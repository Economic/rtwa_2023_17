create_cd118_results <- function(cd_microdata, state_microdata) {
  
  cpi_deflator <- 305.535 / 344.789
  
  state_codes <- tigris::fips_codes %>% 
    distinct(state, state_code, state_name) %>% 
    transmute(
      state_abb = state,
      statefips = as.numeric(state_code),
      state_name
    ) %>% 
    filter(statefips <= 56) %>% 
    as_tibble()
  
  state_values <- state_microdata %>% 
    mutate(affected = direct6 == 1 | indirect6 == 1) %>% 
    summarize(
      state_emp_total = sum(perwt6),
      state_aff_total = sum(affected * perwt6),
      state_dinc_total = sum(d_annual_inc6 * perwt6 * affected, na.rm = TRUE),
      .by = statefips
    )
    
  cd_values <- cd_microdata %>% 
    mutate(affected = direct6 == 1 | indirect6 == 1) %>% 
    summarize(
      cd_emp_total = sum(perwt6),
      cd_aff_total = sum(affected * perwt6),
      cd_dinc_total = sum(d_annual_inc6 * perwt6 * affected, na.rm = TRUE),
      n_aff = sum(affected),
      n_emp = sum(perwt6),
      .by = c(statefips, cd118)
    ) %>% 
    mutate(
      state_emp_total = sum(cd_emp_total),
      state_aff_total = sum(cd_aff_total),
      state_dinc_total = sum(cd_dinc_total),
      .by = statefips
    ) %>% 
    transmute(
      cd_share_state_emp = cd_emp_total / state_emp_total,
      cd_share_state_aff = cd_aff_total / state_aff_total,
      cd_share_state_dinc = cd_dinc_total / state_dinc_total,
      n_aff,
      n_emp,
      statefips,
      cd118
    ) %>% 
    inner_join(state_values, by = "statefips") %>% 
    transmute(
      emp_total = cd_share_state_emp * state_emp_total,
      aff_total = cd_share_state_aff * state_aff_total,
      dinc_total = cd_share_state_dinc * state_dinc_total * cpi_deflator,
      dinc_avg = dinc_total / aff_total,
      aff_share = aff_total / emp_total,
      n_aff,
      n_emp,
      statefips,
      cd118
    ) 
  
  us_values <- cd_values %>% 
    summarize(across(emp_total|aff_total|dinc_total|n_aff, sum)) %>% 
    mutate(
      dinc_avg = dinc_total / aff_total, 
      aff_share = aff_total / emp_total,
      state_abb = "US",
      state_name = "United States"
    ) 
  
  outcomes <- c("aff_total", "aff_share", "dinc_total", "dinc_avg")
    
  cd_values %>%
    # clean results
    # names of states and districts
    inner_join(state_codes, by = "statefips") %>% 
    bind_rows(us_values) %>% 
    mutate(count = sum(n()), .by = statefips) %>% 
    mutate(cd118_chr = case_when(
      state_abb %in% c("DC", "US")  ~ ".",
      count == 1 ~ "Statewide",
      .default = as.character(cd118)
    )) %>%
    # suppress values in accordance with state-specific results
    # first suppress specific states where very few affected
    mutate(across(
      all_of(outcomes),
      ~ if_else(state_abb %in% c("CA", "HI", "WA"), NA, .x)
    )) %>%
    # suppress everything if estimated affected total less than 1500
    mutate(across(
      all_of(outcomes),
      ~ if_else(aff_total < 1500, NA, .x)
    )) %>%
    # suppress everything if estimated affected share less than 0.5%
    mutate(across(
      all_of(outcomes),
      ~ if_else(aff_share < 0.005, NA, .x)
    )) %>%
    # suppress wage stats if sample size affected < 1000
    mutate(across(
      dinc_total|dinc_avg,
      ~ if_else(n_aff < 1000, NA, .x)
    )) %>%
    # round data and deal with units
    mutate(dinc_total = dinc_total / 10^6) %>%
    mutate(across(emp_total|aff_total, ~ round(.x / 1000) * 1000)) %>% 
    mutate(across(
      emp_total|aff_total|dinc_total|dinc_avg,
      ~ scales::label_comma(accuracy = 1)(.x)
    )) %>%
    mutate(aff_share = scales::label_percent(accuracy = 0.1)(aff_share)) %>% 
    # format suppressed as stars
    mutate(across(
      all_of(outcomes),
      ~ if_else(is.na(.x), "*", .x)
    )) %>% 
    # sort data
    mutate(state_name_sort = if_else(state_abb == "US", 0, 1)) %>%
    arrange(state_name_sort, state_name, cd118) %>%
    select(
      "State" = state_name,
      "District" = cd118_chr,
      "Total employed" = emp_total,
      "Total affected" = aff_total,
      "Share affected" = aff_share,
      "Total annual wage change (2023$, millions)" = dinc_total,
      "Average annual wage increase of affected workers (2023$)" = dinc_avg
    )
}