convert_results_rds <- function(microdata_dta) {
  haven::read_dta(microdata_dta) 
  
  # %>% 
  #   mutate(across(where(is.numeric), type_convert_labels))
}


prep_acs_results <- function(acs_microdata, cps_microdata) {
  cps_count <- cps_microdata %>% 
    select(matches("^perwt")) %>% 
    summarize(across(everything(), sum)) %>% 
    pivot_longer(everything()) %>% 
    mutate(step = as.numeric(str_sub(name, 6)))
  
  steps <- cps_count %>% 
    pull(value) %>% 
    length() - 1
  
  for (i in 0:steps) {
    cps_total <- cps_count %>% 
      filter(step == i) %>% 
      pull(value)
    
    acs_var <- paste0("perwt", i)
    
    acs_total <- acs_microdata %>% 
      summarize(sum(.data[[acs_var]])) %>% 
      pull()
    
    acs_microdata <- acs_microdata %>% 
      mutate({{acs_var}} := cps_total / acs_total * .data[[acs_var]])
  }
  
  acs_microdata
    
}