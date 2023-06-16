set more off

global input_clean_dir inputs_clean/
global output_dir outputs/

local stata_arguments = subinstr("`0'", "=", "(", .)
local stata_arguments = subinstr("`stata_arguments'", " ", ") ", .)

capture program drop run_mwsim
program define run_mwsim
syntax, ///
  microdata_file(string) ///
  data_stub(string) ///
  policy_name(string) ///
  policy_schedule_file(string) ///
  cpi_file(string) /// 
  pop_file(string) ///
  state_mw_file(string)
  
  use `policy_schedule_file' if name == "`policy_name'", clear
  sum step
  local steps = r(max)
  tempfile policy_schedule_input
  save `policy_schedule_input'
  
  merge 1:m mdate using `state_mw_file', keep(3) nogenerate
  drop mdate month year
  reshape wide new_mw new_tw stmin tipmin, i(pwstate) j(step)
  drop new_mw0 new_tw0
  label variable stmin0 "State minimum wage in data period"
  label variable tipmin0 "State tipped minimum wage in data period"
  forvalues i = 1/`steps' {
      label variable stmin`i' "State minimum wage at Step `i'"
      label variable tipmin`i' "State tipped minimum wage at Step `i'"

      rename new_mw`i' prop_mw`i'
      rename new_tw`i' prop_tw`i'
  }
  tempfile active_state_mw
  save `active_state_mw'
  
  use `microdata_file', clear 
  gen nom_wage_growth0 = 0.04

  if "`data_stub'" == "cps" {
    merge m:1 pwstate using `active_state_mw', assert(3) nogenerate
  }
  tempfile microdata_input
  save `microdata_input'

  local rwg_value = 0.005
  
  mwsim run, microdata(`microdata_input') policy(`policy_schedule_input') steps(`steps') ///
    cpi(`cpi_file') population(`pop_file') real_wage_growth(`rwg_value')

  save ${output_dir}model_run_microdata_`data_stub'_`policy_name'.dta, replace 

end

run_mwsim, `stata_arguments'


