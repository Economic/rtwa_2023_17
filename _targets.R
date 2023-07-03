## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

tar_plan(
  # do-file targets
  tar_file(dofile_clean_substate_mw, "stata/clean_substate_mw.do"),
  tar_file(dofile_clean_state_mw, "stata/clean_state_mw.do"),
  tar_file(dofile_clean_pop_proj, "stata/clean_pop_projections.do"),
  tar_file(dofile_clean_cpi_proj, "stata/clean_cpi_projections.do"),
  tar_file(dofile_clean_policy_schedules, "stata/clean_policy_schedules.do"),
  tar_file(dofile_clean_cps, "stata/clean_cps.do"),
  tar_file(dofile_clean_acs, "stata/clean_acs.do"),
  tar_file(dofile_clean_acs_cd118, "stata/clean_acs_cd118.do"),
  tar_file(dofile_run_model, "stata/run_model.do"),
  
  # do-file data inputs
  tar_file(pwpumas_dta, "inputs_raw/pwpumas.dta"),
  tar_file(geocorr_puma_cd118, "inputs_raw/geocorr2022_puma2012_cd118.csv"),
  tar_file(state_mw_csv, "inputs_raw/mw_projections_state.csv"),
  tar_file(state_tipmw_csv, "inputs_raw/tipmw_projections_state.csv"),
  tar_file(cpi_proj_csv, "inputs_raw/CPI_projections_2_2023.csv"),
  tar_file(pop_proj_csv, "inputs_raw/pop_projections_8_2020.csv"),
  tar_file(policy_schedules_csv, "inputs_raw/all_scenarios.csv"),
  
  # clean state-level mw projections
  tar_file(
    state_mw_data, 
    do_file_target(dofile_clean_state_mw,
                   mw_csv = state_mw_csv,
                   tipmw_csv = state_tipmw_csv,
                   .outputs = "inputs_clean/state_mins.dta")
  ),
  
  # clean substate-level mw projections
  tar_file(
    substate_mw_data, 
    do_file_target(dofile_clean_substate_mw,
                   pumas_dta = pwpumas_dta,
                   .outputs = "inputs_clean/local_mins.dta")
  ),
  
  # clean cpi projections
  tar_file(
    cpi_proj_data, 
    do_file_target(dofile_clean_cpi_proj,
                   cpi_csv = cpi_proj_csv,
                   .outputs = "inputs_clean/cpi_projections_2_2023.dta")
  ),
  
  # clean pop projections
  tar_file(
    pop_proj_data, 
    do_file_target(dofile_clean_pop_proj,
                   pop_csv = pop_proj_csv,
                   .outputs = "inputs_clean/pop_projections_8_2020.dta")
  ),
  
  # clean scenario inputs
  tar_file(
    policy_schedules, 
    do_file_target(dofile_clean_policy_schedules,
                   scenarios_csv = policy_schedules_csv,
                   .outputs = "inputs_clean/all_scenarios.dta")
  ),
  
  # clean microdata
  tar_file(
    cps_base, 
    do_file_target(dofile_clean_cps,
                   .outputs = "inputs_clean/clean_cps_base.dta")
  ),
  tar_file(
    acs_state_base, 
    do_file_target(dofile_clean_acs,
                   geo = "state",
                   .outputs = "inputs_clean/clean_acs_state_base.dta")
  ),
  tar_file(
    acs_cd118_base,
    do_file_target(dofile_clean_acs_cd118,
                   puma_cd_csv = geocorr_puma_cd118,
                   acs_source_dta = acs_state_base,
                   .outputs = "inputs_clean/clean_acs_cd118_base.dta")
  ),
  
  # run CPS model
  tar_file(
    cps_rtwa_17_2028_ofw,
    do_file_target(dofile_run_model,
                   microdata_file = cps_base,
                   data_stub = "cps",
                   policy_name = "rtwa_17_2028_ofw",
                   policy_schedule_file = policy_schedules,
                   cpi_file = cpi_proj_data,
                   pop_file = pop_proj_data,
                   state_mw_file = state_mw_data,
                   .outputs = "outputs/model_run_microdata_cps_rtwa_17_2028_ofw.dta")
  ),
  # run ACS model
  tar_file(
    acs_state_rtwa_17_2028_ofw,
    do_file_target(dofile_run_model,
                   microdata_file = acs_state_base,
                   data_stub = "acs_state",
                   policy_name = "rtwa_17_2028_ofw",
                   policy_schedule_file = policy_schedules,
                   cpi_file = cpi_proj_data,
                   pop_file = pop_proj_data,
                   state_mw_file = state_mw_data,
                   local_mw_file = substate_mw_data,
                   .outputs = "outputs/model_run_microdata_acs_state_rtwa_17_2028_ofw.dta")
  ),
  
  # convert dta to feather
  tar_format_feather(
    cps_microdata, 
    convert_from_dta(cps_rtwa_17_2028_ofw)
  ),
  tar_format_feather(
    acs_microdata, 
    convert_from_dta(acs_state_rtwa_17_2028_ofw)
  ),
  
  # pin ACS workforce totals to ACS and refine model results
  tar_format_feather(
    acs_results_microdata, 
    prep_acs_results(acs_microdata, cps_microdata)
  ),
  
  # create state-specific results
  state_summary_results = create_state_results(acs_results_microdata),
  
  # create state-specific and national tables
  tar_file(
    state_spreadsheet,
    create_state_spreadsheet(state_summary_results, 
                             "outputs/rtwa_17_2028_state_tables.xlsx")
  )

)
