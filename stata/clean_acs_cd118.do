set more off

global input_clean_dir inputs_clean/

local stata_arguments = subinstr("`0'", "=", "(", .)
local stata_arguments = subinstr("`stata_arguments'", " ", ") ", .)

capture program drop clean_acs_cd118_base
program define clean_acs_cd118_base
syntax, puma_cd_csv(string) acs_source_dta(string)

  import delimited using `puma_cd_csv', clear varnames(1) rowrange(3)
  keep state puma12 cd118 afact
  rename state statefips
  rename puma12 puma
  destring statefips puma cd118 afact, replace
  drop if puma == .
  tempfile puma_cd_map
  save `puma_cd_map'

  use `acs_source_dta', clear
  keep year pwstate pwpuma puma statefips hrwage0 perwt0 female tipc worker uhrswork
  
  joinby statefips puma using `puma_cd_map', unmatched(master)
  assert _merge == 3
  drop _merge
  
  * rescale weights
  
  compress
  save ${input_clean_dir}clean_acs_cd118_base.dta, replace

end

clean_acs_cd118_base, `stata_arguments'
 