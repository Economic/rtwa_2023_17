set more off

global input_clean_dir inputs_clean/

local stata_arguments = subinstr("`0'", "=", "(", .)
local stata_arguments = subinstr("`stata_arguments'", " ", ") ", .)

capture program drop clean_acs_cd118_base
program define clean_acs_cd118_base
syntax, acs_tables_csv(string) puma_cd_csv(string) acs_source_dta(string)

  import delimited using `acs_tables_csv', clear
  keep if profln == 4 | profln == 13
  keep geoid geoname profln title prf_estimate
  rename prf_estimate value
  replace value = subinstr(value, ",", "", .)
  destring value, replace
  gen cd118 =  substr(geoid, -2, .)
  gen statefips = substr(geoid, -4, 2)
  destring cd118, replace
  destring statefips, replace
  drop if statefips == 72
  gen outcome = ""
  replace outcome = "all" if profln == 4
  replace outcome = "fem" if profln == 13
  keep statefips cd118 outcome value
  reshape wide value, i(statefips cd118) j(outcome) string
  rename valueall census_emp_all
  rename valuefem census_emp_fem
  gen census_emp_male = census_emp_all - census_emp_fem
  drop census_emp_all
  tempfile acs_tables_cd
  save `acs_tables_cd'

  import delimited using `puma_cd_csv', clear varnames(1) rowrange(3)
  keep state puma12 cd118 afact
  rename state statefips
  rename puma12 puma
  destring statefips puma cd118 afact, replace
  drop if puma == .
  tempfile puma_cd_map
  save `puma_cd_map'

  use `acs_source_dta', clear
  keep year pwstate pwpuma puma statefips hrwage0 perwt0 female tipc worker uhrswork racec
  
  joinby statefips puma using `puma_cd_map', unmatched(master)
  assert _merge == 3
  drop _merge
  
  * rescale weights
  * first rescale according to population 
  replace perwt0 = perwt0 * afact
  * create scaling factors to match census CD118 gender-specific emp
  preserve
  gcollapse (sum) perwt0_total_ = perwt0, by(statefips cd118 female)
  reshape wide perwt0_total_, i(statefips cd118) j(female)
  rename perwt0_total_1 perwt0_total_fem
  rename perwt0_total_0 perwt0_total_male
  merge 1:1 statefips cd118 using `acs_tables_cd', assert(3) nogenerate
  gen scale_fem = census_emp_fem / perwt0_total_fem
  gen scale_male = census_emp_male / perwt0_total_male
  keep statefips cd118 scale_*
  tempfile weight_scaling
  save `weight_scaling'
  restore
  merge m:1 statefips cd118 using `weight_scaling', assert(3) nogenerate
  replace perwt0 = perwt0 * scale_fem if female == 1
  replace perwt0 = perwt0 * scale_male if female == 0
  drop scale_*
  compress
  save ${input_clean_dir}clean_acs_cd118_base.dta, replace

end

clean_acs_cd118_base, `stata_arguments'
 