set more off

di "hello"

global input_clean_dir inputs_clean/

local stata_arguments = subinstr("`0'", "=", "(", .)
local stata_arguments = subinstr("`stata_arguments'", " ", ") ", .)

capture program drop clean_substate_mw
program define clean_substate_mw 
syntax, pumas_dta(string) 

    *create local minimum wages by PWPUMA for min wage sim model
    *9/20/2020
    *D.Cooper

    * the beginning of this code could use a re-write to avoid using the pre-fab pwpumas dataset.
    clear 
    tempfile mergedpumas
    save `mergedpumas', emptyok
    clear

    forvalues y = 2015/2030 {
        forvalues m = 1/12 {
            use `pumas_dta', clear
            gen month = `m'
            gen year = `y'
            append using `mergedpumas'
            save `mergedpumas', replace
        }
    }

    gen local_mw = .
    gen local_tw = . 

    *Arizona
    **Flagstaff - uses all of Coconino County
    replace local_mw = 10 if pwstate == 4 & pwpuma == 400 & year == 2017 & month < 7  
    replace local_mw = 10.5 if pwstate == 4 & pwpuma == 400 & year == 2017 & month >= 7
    replace local_mw = 11 if pwstate == 4 & pwpuma == 400 & year == 2018
    replace local_mw = 12 if pwstate == 4 & pwpuma == 400 & year == 2019
    replace local_mw = 13 if pwstate == 4 & pwpuma == 400 & year == 2020
    replace local_mw = 15 if pwstate == 4 & pwpuma == 400 & year == 2021
    replace local_mw = 15.5 if pwstate == 4 & pwpuma == 400 & year == 2022
    replace local_mw = 16.80 if pwstate == 4 & pwpuma == 400 & year == 2023
    replace local_mw = 17.60 if pwstate == 4 & pwpuma == 400 & year == 2024
    replace local_mw = 18.15 if pwstate == 4 & pwpuma == 400 & year == 2025
    replace local_mw = 18.55 if pwstate == 4 & pwpuma == 400 & year == 2026
    replace local_mw = 18.95 if pwstate == 4 & pwpuma == 400 & year == 2027
    replace local_mw = 19.35 if pwstate == 4 & pwpuma == 400 & year == 2028
    replace local_mw = 19.80 if pwstate == 4 & pwpuma == 400 & year == 2029

    replace local_tw = 9 if pwstate == 4 & pwpuma == 400 & year == 2017 
    replace local_tw = 9.5 if pwstate == 4 & pwpuma == 400 & year == 2018
    replace local_tw = 10 if pwstate == 4 & pwpuma == 400 & year == 2019
    replace local_tw = 11 if pwstate == 4 & pwpuma == 400 & year == 2020
    replace local_tw = 12 if pwstate == 4 & pwpuma == 400 & year == 2021
    replace local_tw = 13 if pwstate == 4 & pwpuma == 400 & year == 2022
    replace local_tw = 14.8 if pwstate == 4 & pwpuma == 400 & year == 2023
    replace local_tw = 16.10 if pwstate == 4 & pwpuma == 400 & year == 2024
    replace local_tw = 17.15 if pwstate == 4 & pwpuma == 400 & year == 2025
    replace local_tw = 18.55 if pwstate == 4 & pwpuma == 400 & year == 2026
    replace local_tw = 18.95 if pwstate == 4 & pwpuma == 400 & year == 2027
    replace local_tw = 19.35 if pwstate == 4 & pwpuma == 400 & year == 2028
    replace local_tw = 19.80 if pwstate == 4 & pwpuma == 400 & year == 2029

    *Illinios
    **Chicago and Cook County - Uses Cook County minimum
    replace local_mw = 10 if pwstate == 17 & pwpuma == 3400 & year == 2017 & month >= 7
    replace local_mw = 10 if pwstate == 17 & pwpuma == 3400 & year == 2018 & month < 7
    replace local_mw = 11 if pwstate == 17 & pwpuma == 3400 & year == 2018 & month >= 7
    replace local_mw = 11 if pwstate == 17 & pwpuma == 3400 & year == 2019 & month < 7
    replace local_mw = 12 if pwstate == 17 & pwpuma == 3400 & year == 2019 & month >= 7
    replace local_mw = 12 if pwstate == 17 & pwpuma == 3400 & year == 2020 & month < 7
    replace local_mw = 13 if pwstate == 17 & pwpuma == 3400 & year == 2020 & month >= 7
    replace local_mw = 13 if pwstate == 17 & pwpuma == 3400 & year == 2021 & month < 7
    replace local_mw = 13.35 if pwstate == 17 & pwpuma == 3400 & year == 2021 & month >= 7
    replace local_mw = 13.35 if pwstate == 17 & pwpuma == 3400 & year == 2022 & month < 7
    replace local_mw = 13.35 if pwstate == 17 & pwpuma == 3400 & year == 2022 & month >= 7
    replace local_mw = 13.35 if pwstate == 17 & pwpuma == 3400 & year == 2023 & month < 7
    replace local_mw = 13.70 if pwstate == 17 & pwpuma == 3400 & year == 2023 & month >= 7
    replace local_mw = 13.70 if pwstate == 17 & pwpuma == 3400 & year == 2024 & month < 7
    *Illinois State MW will overtake cook county on Jan 1 2024 when it goes to $14, but county ///
        will go above for 6 months in July
    replace local_mw = 14.05 if pwstate == 17 & pwpuma == 3400 & year == 2024 & month >= 7
    * IL State MW will go to 15 in 2025

    replace local_tw = 5.1 if pwstate == 17 & pwpuma == 3400 & year == 2018 & month >= 7
    replace local_tw = 5.1 if pwstate == 17 & pwpuma == 3400 & year == 2019 & month < 7
    replace local_tw = 5.2 if pwstate == 17 & pwpuma == 3400 & year == 2019 & month >= 7
    replace local_tw = 5.2 if pwstate == 17 & pwpuma == 3400 & year == 2020 & month < 7
    replace local_tw = 5.25 if pwstate == 17 & pwpuma == 3400 & year == 2020 & month >= 7
    replace local_tw = 5.25 if pwstate == 17 & pwpuma == 3400 & year == 2021 & month < 7
    replace local_tw = 5.40 if pwstate == 17 & pwpuma == 3400 & year == 2021 & month >= 7
    replace local_tw = 5.40 if pwstate == 17 & pwpuma == 3400 & year == 2022 & month < 7
    replace local_tw = 5.55 if pwstate == 17 & pwpuma == 3400 & year == 2022 & month >= 7
    replace local_tw = 5.55 if pwstate == 17 & pwpuma == 3400 & year == 2023 & month < 7
    replace local_tw = 5.70 if pwstate == 17 & pwpuma == 3400 & year == 2023 & month >= 7
    replace local_tw = 5.70 if pwstate == 17 & pwpuma == 3400 & year == 2024 & month < 7
    replace local_tw = 5.85 if pwstate == 17 & pwpuma == 3400 & year == 2024 & month >= 7
    replace local_tw = 5.85 if pwstate == 17 & pwpuma == 3400 & year == 2025 & month < 7
    replace local_tw = 6 if pwstate == 17 & pwpuma == 3400 & year == 2025 & month >= 7
    replace local_tw = 6 if pwstate == 17 & pwpuma == 3400 & year == 2026 & month < 7
    replace local_tw = 6.10 if pwstate == 17 & pwpuma == 3400 & year == 2026 & month >= 7
    replace local_tw = 6.10 if pwstate == 17 & pwpuma == 3400 & year == 2027 & month < 7
    replace local_tw = 6.25 if pwstate == 17 & pwpuma == 3400 & year == 2027 & month >= 7
    replace local_tw = 6.25 if pwstate == 17 & pwpuma == 3400 & year == 2028 & month < 7
    replace local_tw = 6.4 if pwstate == 17 & pwpuma == 3400 & year == 2028 & month >= 7
    replace local_tw = 6.4 if pwstate == 17 & pwpuma == 3400 & year == 2029 & month < 7
    replace local_tw = 6.55 if pwstate == 17 & pwpuma == 3400 & year == 2029 & month >= 7
    replace local_tw = 6.55 if pwstate == 17 & pwpuma == 3400 & year == 2030 & month < 7

    *Maine
    **Portland and surrounding areas (SE Maine)
    replace local_mw = 10.1 if pwstate == 23 & pwpuma == 790 & year == 2016
    replace local_mw = 10.68 if pwstate == 23 & pwpuma == 790 & year == 2017
    replace local_mw = 10.68 if pwstate == 23 & pwpuma == 790 & year == 2018 & month < 7
    replace local_mw = 10.9 if pwstate == 23 & pwpuma == 790 & year == 2018 & month >= 7
    replace local_mw = 11.00 if pwstate == 23 & pwpuma == 790 & year == 2019 & month < 7
    replace local_mw = 11.17 if pwstate == 23 & pwpuma == 790 & year == 2019 & month >= 7
    replace local_mw = 12.00 if pwstate == 23 & pwpuma == 790 & year == 2020
    replace local_mw = 12.15 if pwstate == 23 & pwpuma == 790 & year == 2021
    replace local_mw = 12.75 if pwstate == 23 & pwpuma == 790 & year == 2022
    replace local_mw = 14.00 if pwstate == 23 & pwpuma == 790 & year == 2023
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2024
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2025
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2026
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2027
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2028
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2029
    replace local_mw = 15.00 if pwstate == 23 & pwpuma == 790 & year == 2030
    *State TW is above local TW from 2017 onward

    *Maryland
    **Montgomery County
    replace local_mw = 8.4 if pwstate == 24 & pwpuma == 1000 & year == 2014 & month >= 10
    replace local_mw = 8.4 if pwstate == 24 & pwpuma == 1000 & year == 2015 & month < 10
    replace local_mw = 9.55 if pwstate == 24 & pwpuma == 1000 & year == 2015 & month >= 10
    replace local_mw = 9.55 if pwstate == 24 & pwpuma == 1000 & year == 2016 & month < 10
    replace local_mw = 10.75 if pwstate == 24 & pwpuma == 1000 & year == 2016 & month >= 10
    replace local_mw = 10.75 if pwstate == 24 & pwpuma == 1000 & year == 2017 & month < 10
    replace local_mw = 11.50 if pwstate == 24 & pwpuma == 1000 & year == 2017 & month >= 10
    replace local_mw = 11.50 if pwstate == 24 & pwpuma == 1000 & year == 2018 & month < 7
    replace local_mw = 12.25 if pwstate == 24 & pwpuma == 1000 & year == 2018 & month >= 7
    replace local_mw = 12.25 if pwstate == 24 & pwpuma == 1000 & year == 2019 & month < 7
    replace local_mw = 13 if pwstate == 24 & pwpuma == 1000 & year == 2019 & month >= 7
    replace local_mw = 13 if pwstate == 24 & pwpuma == 1000 & year == 2020 & month < 7
    replace local_mw = 14 if pwstate == 24 & pwpuma == 1000 & year == 2020 & month >= 7
    replace local_mw = 14 if pwstate == 24 & pwpuma == 1000 & year == 2021 & month < 7
    replace local_mw = 15 if pwstate == 24 & pwpuma == 1000 & year == 2021 & month >= 7
    replace local_mw = 15 if pwstate == 24 & pwpuma == 1000 & year == 2022 & month < 7
    replace local_mw = 15.65 if pwstate == 24 & pwpuma == 1000 & year == 2022 & month >= 7
    replace local_mw = 15.65 if pwstate == 24 & pwpuma == 1000 & year == 2023 & month < 7
    replace local_mw = 16.90 if pwstate == 24 & pwpuma == 1000 & year == 2023 & month >= 7
    replace local_mw = 16.90 if pwstate == 24 & pwpuma == 1000 & year == 2024 & month < 7
    replace local_mw = 17.73 if pwstate == 24 & pwpuma == 1000 & year == 2024 & month >= 7
    replace local_mw = 17.73 if pwstate == 24 & pwpuma == 1000 & year == 2025 & month < 7
    replace local_mw = 18.26 if pwstate == 24 & pwpuma == 1000 & year == 2025 & month >= 7
    replace local_mw = 18.26 if pwstate == 24 & pwpuma == 1000 & year == 2026 & month < 7
    replace local_mw = 18.66 if pwstate == 24 & pwpuma == 1000 & year == 2026 & month >= 7
    replace local_mw = 18.66 if pwstate == 24 & pwpuma == 1000 & year == 2027 & month < 7
    replace local_mw = 19.04 if pwstate == 24 & pwpuma == 1000 & year == 2027 & month >= 7
    replace local_mw = 19.04 if pwstate == 24 & pwpuma == 1000 & year == 2028 & month < 7
    replace local_mw = 19.43 if pwstate == 24 & pwpuma == 1000 & year == 2028 & month >= 7
    replace local_mw = 19.43 if pwstate == 24 & pwpuma == 1000 & year == 2029 & month < 7
    replace local_mw = 19.86 if pwstate == 24 & pwpuma == 1000 & year == 2029 & month >= 7
    replace local_mw = 19.86 if pwstate == 24 & pwpuma == 1000 & year == 2030 & month < 7
    replace local_mw = 20.31 if pwstate == 24 & pwpuma == 1000 & year == 2030 & month >= 7

    replace local_tw = 4 if pwstate == 24 & pwpuma == 1000 & year == 2014 & month >= 10
    replace local_tw = 4 if pwstate == 24 & pwpuma == 1000 & year > 2014 & year != .

    **Prince Georges County
    replace local_mw = 8.4 if pwstate == 24 & pwpuma == 1100 & year == 2014 & month >= 10
    replace local_mw = 8.4 if pwstate == 24 & pwpuma == 1100 & year == 2015 & month < 10
    replace local_mw = 9.55 if pwstate == 24 & pwpuma == 1100 & year == 2015 & month >= 10
    replace local_mw = 9.55 if pwstate == 24 & pwpuma == 1100 & year == 2016 & month < 10
    replace local_mw = 10.75 if pwstate == 24 & pwpuma == 1100 & year == 2016 & month >= 10
    replace local_mw = 10.75 if pwstate == 24 & pwpuma == 1100 & year == 2017 & month < 10
    replace local_mw = 11.50 if pwstate == 24 & pwpuma == 1100 & year == 2017 & month >= 10
    replace local_mw = 11.50 if pwstate == 24 & pwpuma == 1100 & year >= 2018 & month != .
    *PGC has no local tipped min - it's equal to the state tipped min

    *Minnesota
    **Minneapolis
    replace local_mw = 10 if pwstate == 27 & pwpuma == 1400 & year == 2018 & month < 7
    replace local_mw = 11.25 if pwstate == 27 & pwpuma == 1400 & year == 2018 & month >= 7
    replace local_mw = 11.25 if pwstate == 27 & pwpuma == 1400 & year == 2019 & month < 7
    replace local_mw = 12.25 if pwstate == 27 & pwpuma == 1400 & year == 2019 & month >= 7
    replace local_mw = 12.25 if pwstate == 27 & pwpuma == 1400 & year == 2020 & month < 7
    replace local_mw = 13.25 if pwstate == 27 & pwpuma == 1400 & year == 2020 & month >= 7
    replace local_mw = 13.25 if pwstate == 27 & pwpuma == 1400 & year == 2021 & month < 7
    replace local_mw = 14.25 if pwstate == 27 & pwpuma == 1400 & year == 2021 & month >= 7
    replace local_mw = 14.25 if pwstate == 27 & pwpuma == 1400 & year == 2022 & month < 7
    replace local_mw = 15 if pwstate == 27 & pwpuma == 1400 & year == 2022 & month >= 7
    replace local_mw = 15.19 if pwstate == 27 & pwpuma == 1400 & year == 2023 
    replace local_mw = 15.57 if pwstate == 27 & pwpuma == 1400 & year == 2024
    replace local_mw = 15.96 if pwstate == 27 & pwpuma == 1400 & year == 2025
    replace local_mw = 16.31 if pwstate == 27 & pwpuma == 1400 & year == 2026
    replace local_mw = 16.64 if pwstate == 27 & pwpuma == 1400 & year == 2027
    replace local_mw = 16.98 if pwstate == 27 & pwpuma == 1400 & year == 2028
    replace local_mw = 17.36 if pwstate == 27 & pwpuma == 1400 & year == 2029
    replace local_mw = 17.75 if pwstate == 27 & pwpuma == 1400 & year == 2030

    replace local_tw = 10 if pwstate == 27 & pwpuma == 1400 & year == 2018 & month < 7
    replace local_tw = 11.25 if pwstate == 27 & pwpuma == 1400 & year == 2018 & month >= 7
    replace local_tw = 11.25 if pwstate == 27 & pwpuma == 1400 & year == 2019 & month < 7
    replace local_tw = 12.25 if pwstate == 27 & pwpuma == 1400 & year == 2019 & month >= 7
    replace local_tw = 12.25 if pwstate == 27 & pwpuma == 1400 & year == 2020 & month < 7
    replace local_tw = 13.25 if pwstate == 27 & pwpuma == 1400 & year == 2020 & month >= 7
    replace local_tw = 13.25 if pwstate == 27 & pwpuma == 1400 & year == 2021 & month < 7
    replace local_tw = 14.25 if pwstate == 27 & pwpuma == 1400 & year == 2021 & month >= 7
    replace local_tw = 14.25 if pwstate == 27 & pwpuma == 1400 & year == 2022 & month < 7
    replace local_tw = 15 if pwstate == 27 & pwpuma == 1400 & year == 2022 & month >= 7
    replace local_tw = 15.19 if pwstate == 27 & pwpuma == 1400 & year == 2023 
    replace local_tw = 15.57 if pwstate == 27 & pwpuma == 1400 & year == 2024
    replace local_tw = 15.96 if pwstate == 27 & pwpuma == 1400 & year == 2025
    replace local_tw = 16.31 if pwstate == 27 & pwpuma == 1400 & year == 2026
    replace local_tw = 16.64 if pwstate == 27 & pwpuma == 1400 & year == 2027
    replace local_tw = 16.98 if pwstate == 27 & pwpuma == 1400 & year == 2028
    replace local_tw = 17.36 if pwstate == 27 & pwpuma == 1400 & year == 2029
    replace local_tw = 17.75 if pwstate == 27 & pwpuma == 1400 & year == 2030

    **St. Paul
    replace local_mw = 12.50 if pwstate == 27 & pwpuma == 1300 & year >= 2020 & year < 2022
    replace local_mw = 12.50 if pwstate == 27 & pwpuma == 1300 & year == 2022 & month < 7
    replace local_mw = 15 if pwstate == 27 & pwpuma == 1300 & year == 2022 & month >= 7
    replace local_mw = 15.19 if pwstate == 27 & pwpuma == 1300 & year == 2023
    replace local_mw = 15.57 if pwstate == 27 & pwpuma == 1300 & year == 2024
    replace local_mw = 15.96 if pwstate == 27 & pwpuma == 1300 & year == 2025
    replace local_mw = 16.31 if pwstate == 27 & pwpuma == 1300 & year == 2026
    replace local_mw = 16.64 if pwstate == 27 & pwpuma == 1300 & year == 2027
    replace local_mw = 16.98 if pwstate == 27 & pwpuma == 1300 & year == 2028
    replace local_mw = 17.36 if pwstate == 27 & pwpuma == 1300 & year == 2029
    replace local_mw = 17.75 if pwstate == 27 & pwpuma == 1300 & year == 2030

    replace local_tw = 12.50 if pwstate == 27 & pwpuma == 1300 & year >= 2020 & year < 2022
    replace local_tw = 12.50 if pwstate == 27 & pwpuma == 1300 & year == 2022 & month < 7
    replace local_tw = 15 if pwstate == 27 & pwpuma == 1300 & year == 2022 & month >= 7
    replace local_tw = 15 if pwstate == 27 & pwpuma == 1300 & year == 2023 & month < 7
    replace local_tw = 15.32 if pwstate == 27 & pwpuma == 1300 & year == 2023 & month >= 7
    replace local_tw = 15.19 if pwstate == 27 & pwpuma == 1300 & year == 2023
    replace local_tw = 15.57 if pwstate == 27 & pwpuma == 1300 & year == 2024
    replace local_tw = 15.96 if pwstate == 27 & pwpuma == 1300 & year == 2025
    replace local_tw = 16.31 if pwstate == 27 & pwpuma == 1300 & year == 2026
    replace local_tw = 16.64 if pwstate == 27 & pwpuma == 1300 & year == 2027
    replace local_tw = 16.98 if pwstate == 27 & pwpuma == 1300 & year == 2028
    replace local_tw = 17.36 if pwstate == 27 & pwpuma == 1300 & year == 2029
    replace local_tw = 17.75 if pwstate == 27 & pwpuma == 1300 & year == 2030

    *New Mexico
    **ABQ - Uses all of Bernalillo County
    replace local_mw = 8.6 if pwstate == 35 & pwpuma == 790 & year == 2014
    replace local_mw = 8.75 if pwstate == 35 & pwpuma == 790 & year == 2015
    replace local_mw = 8.75 if pwstate == 35 & pwpuma == 790 & year == 2016
    replace local_mw = 8.8 if pwstate == 35 & pwpuma == 790 & year == 2017
    replace local_mw = 8.95 if pwstate == 35 & pwpuma == 790 & year == 2018
    replace local_mw = 9.2 if pwstate == 35 & pwpuma == 790 & year == 2019
    replace local_mw = 9.35 if pwstate == 35 & pwpuma == 790 & year == 2020
    replace local_mw = 9.45 if pwstate == 35 & pwpuma == 790 & year == 2021
    replace local_mw = 9.90 if pwstate == 35 & pwpuma == 790 & year == 2022
    replace local_mw = 10.70 if pwstate == 35 & pwpuma == 790 & year == 2023
    replace local_mw = 11.20 if pwstate == 35 & pwpuma == 790 & year == 2024
    replace local_mw = 11.55 if pwstate == 35 & pwpuma == 790 & year == 2025
    replace local_mw = 11.80 if pwstate == 35 & pwpuma == 790 & year == 2026
    replace local_mw = 12.05 if pwstate == 35 & pwpuma == 790 & year == 2027
    replace local_mw = 12.30 if pwstate == 35 & pwpuma == 790 & year == 2028
    replace local_mw = 12.55 if pwstate == 35 & pwpuma == 790 & year == 2029
    replace local_mw = 12.85 if pwstate == 35 & pwpuma == 790 & year == 2030

    *Bernalillo county doesn't have a tipped minimum. ABQ does, but sticking with Bernalillo 
    *due to PWPUMA scope

    **Santa Fe - using all of Santa Fe County
    replace local_mw = 10.29 if pwstate == 35 & pwpuma == 500 & year == 2012 & month >=3
    replace local_mw = 10.29 if pwstate == 35 & pwpuma == 500 & year == 2013 & month <3
    replace local_mw = 10.51 if pwstate == 35 & pwpuma == 500 & year == 2013 & month >=3
    replace local_mw = 10.51 if pwstate == 35 & pwpuma == 500 & year == 2014 & month <3
    replace local_mw = 10.66 if pwstate == 35 & pwpuma == 500 & year == 2014 & month >=3
    replace local_mw = 10.66 if pwstate == 35 & pwpuma == 500 & year == 2015 & month <3
    replace local_mw = 10.84 if pwstate == 35 & pwpuma == 500 & year == 2015 & month >=3
    replace local_mw = 10.84 if pwstate == 35 & pwpuma == 500 & year == 2016 & month <3
    replace local_mw = 10.91 if pwstate == 35 & pwpuma == 500 & year == 2016 & month >=3
    replace local_mw = 10.91 if pwstate == 35 & pwpuma == 500 & year == 2017 & month <3
    replace local_mw = 11.09 if pwstate == 35 & pwpuma == 500 & year == 2017 & month >=3
    replace local_mw = 11.09 if pwstate == 35 & pwpuma == 500 & year == 2018 & month <3
    replace local_mw = 11.40 if pwstate == 35 & pwpuma == 500 & year == 2018 & month >=3
    replace local_mw = 11.40 if pwstate == 35 & pwpuma == 500 & year == 2019 & month <3
    replace local_mw = 11.68 if pwstate == 35 & pwpuma == 500 & year == 2019 & month >=3
    replace local_mw = 11.68 if pwstate == 35 & pwpuma == 500 & year == 2020 & month <3
    replace local_mw = 11.89 if pwstate == 35 & pwpuma == 500 & year == 2020 & month >=3
    replace local_mw = 11.89 if pwstate == 35 & pwpuma == 500 & year == 2021 & month <3
    replace local_mw = 12.32 if pwstate == 35 & pwpuma == 500 & year == 2021 & month >=3
    replace local_mw = 12.32 if pwstate == 35 & pwpuma == 500 & year == 2022 & month <3
    replace local_mw = 12.95 if pwstate == 35 & pwpuma == 500 & year == 2022 & month >=3
    replace local_mw = 12.95 if pwstate == 35 & pwpuma == 500 & year == 2023 & month <3
    replace local_mw = 13.99 if pwstate == 35 & pwpuma == 500 & year == 2023 & month >=3
    replace local_mw = 13.99 if pwstate == 35 & pwpuma == 500 & year == 2024 & month <3
    replace local_mw = 14.67 if pwstate == 35 & pwpuma == 500 & year == 2024 & month >=3
    replace local_mw = 14.67 if pwstate == 35 & pwpuma == 500 & year == 2025 & month <3
    replace local_mw = 15.11 if pwstate == 35 & pwpuma == 500 & year == 2025 & month >=3
    replace local_mw = 15.11 if pwstate == 35 & pwpuma == 500 & year == 2026 & month <3
    replace local_mw = 15.44 if pwstate == 35 & pwpuma == 500 & year == 2026 & month >=3
    replace local_mw = 15.44 if pwstate == 35 & pwpuma == 500 & year == 2027 & month <3
    replace local_mw = 15.76 if pwstate == 35 & pwpuma == 500 & year == 2027 & month >=3
    replace local_mw = 15.76 if pwstate == 35 & pwpuma == 500 & year == 2028 & month <3
    replace local_mw = 16.08 if pwstate == 35 & pwpuma == 500 & year == 2028 & month >=3
    replace local_mw = 16.08 if pwstate == 35 & pwpuma == 500 & year == 2029 & month <3
    replace local_mw = 16.44 if pwstate == 35 & pwpuma == 500 & year == 2029 & month >=3
    replace local_mw = 16.44 if pwstate == 35 & pwpuma == 500 & year == 2030 & month <3
    replace local_mw = 16.80 if pwstate == 35 & pwpuma == 500 & year == 2030 & month >=3
    replace local_mw = 16.80 if pwstate == 35 & pwpuma == 500 & year == 2031 & month <3

    *County tipped min is 30% of regular min. Santa Fe City has no tipped min
    replace local_tw = (.3 * local_mw) if pwstate == 35 & pwpuma == 500 & year <= 2030 ///
        & year > 2011

    **Las Cruces - uses all of Dona Ana County (PWPUMA=1000)
    replace local_mw = 8.4 if pwstate == 35 & pwpuma == 1000 & year == 2015 
    replace local_mw = 8.4 if pwstate == 35 & pwpuma == 1000 & year == 2016
    replace local_mw = 9.2 if pwstate == 35 & pwpuma == 1000 & year == 2017
    replace local_mw = 9.2 if pwstate == 35 & pwpuma == 1000 & year == 2018
    replace local_mw = 10.1 if pwstate == 35 & pwpuma == 1000 & year == 2019
    replace local_mw = 10.3 if pwstate == 35 & pwpuma == 1000 & year == 2020
    replace local_mw = 10.45 if pwstate == 35 & pwpuma == 1000 & year == 2021
    replace local_mw = 10.95 if pwstate == 35 & pwpuma == 1000 & year == 2022
    replace local_mw = 11.85 if pwstate == 35 & pwpuma == 1000 & year == 2023
    replace local_mw = 12.45 if pwstate == 35 & pwpuma == 1000 & year == 2024
    replace local_mw = 12.85 if pwstate == 35 & pwpuma == 1000 & year == 2025
    replace local_mw = 13.15 if pwstate == 35 & pwpuma == 1000 & year == 2026
    replace local_mw = 13.40 if pwstate == 35 & pwpuma == 1000 & year == 2027
    replace local_mw = 13.70 if pwstate == 35 & pwpuma == 1000 & year == 2028
    replace local_mw = 14.00 if pwstate == 35 & pwpuma == 1000 & year == 2029
    replace local_mw = 14.30 if pwstate == 35 & pwpuma == 1000 & year == 2030

    *tipped minimum is 40% of regular minimum
    replace local_tw = (.4 * local_mw) if pwstate == 35 & pwpuma == 1000 & year <= 2030 ///
        & year > 2014

    *New York
    **NYC
    replace local_mw = 11 if pwstate == 36 & inlist(pwpuma, 3700,3800,3900,4000,4100) ///
        & year == 2017
    replace local_mw = 13 if pwstate == 36 & inlist(pwpuma, 3700,3800,3900,4000,4100) ///
        & year == 2018
    replace local_mw = 15 if pwstate == 36 & inlist(pwpuma, 3700,3800,3900,4000,4100) ///
        & year >= 2019

    replace local_tw = 8.65 if pwstate == 36 & inlist(pwpuma, 3700,3800,3900,4000,4100) ///
        & year == 2018
    replace local_tw = 10 if pwstate == 36 & inlist(pwpuma, 3700,3800,3900,4000,4100) ///
        & year >= 2019

    **Nassau, Suffolk, Westchester Counties
    replace local_mw = 10 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2017
    replace local_mw = 11 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2018
    replace local_mw = 12 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2019
    replace local_mw = 13 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2020
    replace local_mw = 14 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2021
    replace local_mw = 15 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year >= 2022

    replace local_tw = 8 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2019
    replace local_tw = 8.65 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2020
    replace local_tw = 9.35 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year == 2021
    replace local_tw = 10 if pwstate == 36 & inlist(pwpuma, 3100,3200,3300) ///
        & year >= 2022

    *Oregon
    **Portland Urban Growth Area
    replace local_mw = 11.25 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2017 ///
        & month >= 7
    replace local_mw = 11.25 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2018 ///
        & month < 7
    replace local_mw = 12 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2018 ///
        & month >= 7
    replace local_mw = 12 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2019 ///
        & month < 7
    replace local_mw = 12.5 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2019 ///
        & month >= 7
    replace local_mw = 12.5 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2020 ///
        & month < 7
    replace local_mw = 13.25 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2020 ///
        & month >= 7
    replace local_mw = 13.25 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2021 ///
        & month < 7
    replace local_mw = 14 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2021 ///
        & month >= 7
    replace local_mw = 14 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2022 ///
        & month < 7
    replace local_mw = 14.75 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2022 ///
        & month >= 7
    replace local_mw = 14.75 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2023 ///
        & month < 7
    replace local_mw = 15.85 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2023 ///
        & month >= 7
    replace local_mw = 15.85 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2024 ///
        & month < 7
    replace local_mw = 16.55 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2024 ///
        & month >= 7
    replace local_mw = 16.55 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2025 ///
        & month < 7
    replace local_mw = 17.00 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2025 ///
        & month >= 7
    replace local_mw = 17.00 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2026 ///
        & month < 7
    replace local_mw = 17.35 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2026 ///
        & month >= 7
    replace local_mw = 17.35 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2027 ///
        & month < 7
    replace local_mw = 17.70 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2027 ///
        & month >= 7
    replace local_mw = 17.70 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2028 ///
        & month < 7
    replace local_mw = 18.05 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2028 ///
        & month >= 7
    replace local_mw = 18.05 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2029 ///
        & month < 7
    replace local_mw = 18.40 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2029 ///
        & month >= 7
    replace local_mw = 18.40 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2030 ///
        & month < 7
    replace local_mw = 18.80 if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year == 2030 ///
        & month >= 7

    replace local_tw = local_mw if pwstate == 41 & inlist(pwpuma,1325,1326,1327) & year <= 2030 & year > 2016

    **Nonurban counties
    replace local_mw = 10 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2017 ///
        & month >= 7
    replace local_mw = 10 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2018 ///
        & month < 7
    replace local_mw = 10.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2018 ///
        & month >= 7
    replace local_mw = 10.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2019 ///
        & month < 7
    replace local_mw = 11 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2019 ///
        & month >= 7
    replace local_mw = 11 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2020 ///
        & month < 7
    replace local_mw = 11.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2020 ///
        & month >= 7
    replace local_mw = 11.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2021 ///
        & month < 7
    replace local_mw = 12 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2021 ///
        & month >= 7
    replace local_mw = 12 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2022 ///
        & month < 7
    replace local_mw = 12.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2022 ///
        & month >= 7
    replace local_mw = 12.5 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2023 ///
        & month < 7
    replace local_mw = 13.60 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2023 ///
        & month >= 7
    replace local_mw = 13.60 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2024 ///
        & month < 7
    replace local_mw = 14.30 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2024 ///
        & month >= 7
    replace local_mw = 14.30 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2025 ///
        & month < 7
    replace local_mw = 14.75 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2025 ///
        & month >= 7
    replace local_mw = 14.75 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2026 ///
        & month < 7
    replace local_mw = 15.10 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2026 ///
        & month >= 7
    replace local_mw = 15.10 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2027 ///
        & month < 7
    replace local_mw = 15.45 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2027 ///
        & month >= 7
    replace local_mw = 15.45 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2028 ///
        & month < 7
    replace local_mw = 15.80 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2028 ///
        & month >= 7
    replace local_mw = 15.80 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2029 ///
        & month < 7
    replace local_mw = 16.15 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2029 ///
        & month >= 7
    replace local_mw = 16.15 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2030 ///
        & month < 7
    replace local_mw = 16.55 if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year == 2030 ///
        & month >= 7

    replace local_tw = local_mw if pwstate == 41 & inlist(pwpuma,100,200,300,800,1000) & year <= 2030 & year > 2016

    *Washington
    **Seattle - includes SEATAC and all of King County
    replace local_mw = 11 if pwstate == 53 & pwpuma == 11600 & year == 2015 & month >= 4
    replace local_mw = 13 if pwstate == 53 & pwpuma == 11600 & year == 2016 
    replace local_mw = 15 if pwstate == 53 & pwpuma == 11600 & year == 2017
    replace local_mw = 15.45 if pwstate == 53 & pwpuma == 11600 & year == 2018
    replace local_mw = 16 if pwstate == 53 & pwpuma == 11600 & year == 2019
    replace local_mw = 16.29 if pwstate == 53 & pwpuma == 11600 & year == 2020
    replace local_mw = 16.49 if pwstate == 53 & pwpuma == 11600 & year == 2021
    replace local_mw = 17.54 if pwstate == 53 & pwpuma == 11600 & year == 2022
    replace local_mw = 18.69 if pwstate == 53 & pwpuma == 11600 & year == 2023
    replace local_mw = 19.60 if pwstate == 53 & pwpuma == 11600 & year == 2024
    replace local_mw = 20.19 if pwstate == 53 & pwpuma == 11600 & year == 2025
    replace local_mw = 20.63 if pwstate == 53 & pwpuma == 11600 & year == 2026
    replace local_mw = 21.06 if pwstate == 53 & pwpuma == 11600 & year == 2027
    replace local_mw = 21.49 if pwstate == 53 & pwpuma == 11600 & year == 2028
    replace local_mw = 21.96 if pwstate == 53 & pwpuma == 11600 & year == 2029
    replace local_mw = 22.45 if pwstate == 53 & pwpuma == 11600 & year == 2030

    replace local_tw = local_mw if pwstate == 53 & pwpuma == 11600 & year > 2014 & year < 2031

    **Takoma
    * superceded by state min wage in 2020
    replace local_mw = 10.35 if pwstate == 53 & pwpuma == 11500 & year == 2016 & month >= 2
    replace local_mw = 11.15 if pwstate == 53 & pwpuma == 11500 & year == 2017 
    replace local_mw = 12 if pwstate == 53 & pwpuma == 11500 & year == 2018
    replace local_mw = 12.35 if pwstate == 53 & pwpuma == 11500 & year == 2019

    replace local_tw = local_mw if pwstate == 53 & pwpuma == 11500 & year > 2015 & year < 2020

    keep if local_mw != .

    gen mdate = ym(year,month)
    format %tm mdate

    label variable mdate "Month and Year"
    label variable pwstate "State FIPS code"
    label variable pwpuma "Place of Work PUMA"

    save ${input_clean_dir}local_mins.dta, replace

end

clean_substate_mw, `stata_arguments'
