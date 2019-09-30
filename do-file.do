clear
cd "/wdir"
log using res.log, replace
import excel "db0_", sheet("Sheet1") firstrow

*** (just in case there is a need for numeric Country) gen ID = sum(Country != Country[_n-1])
gen ID = sum(Country != Country[_n-1])
tab ID
list Country Survey if dhs_y<=1986
list Country Survey if dhs_y>=2018
*********140 DHSs among 41 SSA countries from 1986 to 2017-18

*** Number of DHSs per country
bysort Country: gen nbr = _N
lab var nbr"Number of DHSs"
tab nbr


*** Rank survey number by country in descending order (as STATcompiler provide DHS edition from the less recent to the earlier
egen upw = rank(-_n), by(Country)
lab var upw"Survey order"

*** Reverse order of DHSs
bysort Country : gen dnw = _n

list Survey upw dnw, sepby(Country)

*** Excluding countries with less than 3 DHSs
drop if nbr<3

*** Inter-survey period
bysort Country : gen dT = dhs_y[_n] - dhs_y[_n+1]

*** Change in TFRs
bysort Country : gen dTFR = ((TFR[_n]/TFR[_n+1] - 1)*100)

list Country Survey dT dTFR, sepby(Country)

sort Country upw

****Stalling in fertility decline status
****Condition 1: Pretransitional countries (mean(TFR)>6) and those approaching the replacement level
bysort Country (upw) : egen avTFR = mean(TFR)
bysort Country (upw) : gen pre_rep=0 if avTFR > 6 & avTFR[_n] > 5 & avTFR <.
bysort Country (upw) : replace pre_rep=1 if avTFR[_n] < 2.1

***Fixing .... country near replacement level at once

bysort Country (upw) : egen c_rep = max(pre_rep)
lab var pre_rep"Classifiction of fertility trends"
lab def pre_rep 0"Pre-transitional" 1"Replacement level"
lab val pre_rep pre_rep
tab Country pre_rep

***Intermediate data
save for_graph, replace
clear
use for_graph

list Country TFR if pre_rep==0
list Country TFR if c_rep==1

drop if pre_rep==0 | c_rep==1


****Condition 2: a decline has already started
********counting fertility decline occurrence
bysort Country (upw) : gen decl_ct = sum(dTFR<0) if _n != 1
bysort Country (upw) : gen stall=(dTFR>=0 & decl_ct>=1) if _n != 1

list Country Survey dT TFR dTFR avTFR stall, sepby(Country)

****Countries with fertility shifting from stall to decline 
********counting stall in fertility decline occurrence
bysort Country (upw) : gen stall_ct = sum(stall==1) if _n >= 3
bysort Country (upw) : gen st_to_decline=(dTFR<0 & stall_ct>=1) if _n >= 3

***Fixing ... country that resume fertility decline at least once
bysort Country (dnw) : egen c_stdec = max(st_to_decline)

***Countries with >=4 DHSs
keep if nbr>=4

list Country Survey dT TFR dTFR avTFR stall st_to_decline if c_stdec==1, sepby(Country)
tab Country st_to_decline


foreach var of varlist x* {
	bysort Country : gen d`var' = `var'[_n] - `var'[_n+1]
}

lab var dx_RHEnv1 "Current users most recent supply or information from a public source"
lab var dx_RHEnv2 "First-year contraceptive discontinuation rate due to all reasons"
lab var dx_RHEnv3 "Demand for family planning satisfied by modern methods"
lab var dx_RHEnv4 "Total demand for family planning"
lab var dx_RHEnv5 "Receive Family planning information from media"
lab var dx_SE1 "Net secondary school attendance rate: Female"
lab var dx_SE2 "Women's occupation: Professional, technical, managerial"
lab var dx_SE3 "Women who worked seasonally"
lab var dx_SE4 "Women who worked occasionally"
lab var dx_SE5 "Percentage of households with electricity"
lab var dx_RHBeh1 "Median age at first birth for women age 20-24"
lab var dx_RHBeh2 "Median age at first birth for women age 20-49"
lab var dx_RHBeh3 "Total wanted fertility rate"
lab var dx_RHBeh4 "Current use of any method of contraception"
lab var dx_RHBeh5 "Median age at first marriage [Women]: 20-24"
lab var dx_RHBeh6 "Median age at first marriage [Women]: 20-49"
lab var dx_RHBeh7 "Under-five mortality rate"

probit st_to_decline dx_RHEnv1 dx_RHEnv3 dx_SE5 dx_RHBeh3 dx_RHBeh4 dx_RHBeh7
