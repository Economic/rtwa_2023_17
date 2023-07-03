set more off

import delimited using inputs_raw/DP03_1yr_500.csv, clear 
keep if profln == 4 | profln == 10
keep geoid geoname profln title prf_estimate
rename prf_estimate value
replace value = subinstr(value, ",", "", .)
destring value, replace
gen cd118 =  substr(geoid, -2, .)
gen statefips = substr(geoid, -4, 2)
destring cd118, replace
destring statefips, replace
drop if statefips == 72
keep if profln == 4
tempfile acs_tables_cd
save `acs_tables_cd'

use inputs_clean/clean_acs_cd118_base.dta, clear 
merge m:1 statefips cd118 using `acs_tables_cd'


