clear all

global root "C:\Users\jhony\Google Drive\Universidades\University of Chicago\Courses\3. Spring Quarter\Social Network Analysis\Final project\Paper\Data"

global path_inputs  "$root\1_Inputs"
global path_aux 	"$root\2_Aux"
global path_outputs	"$root\3_Outputs"

use "$path_inputs/22140-0002-Data.dta"

* Checking that relevant variables are present in every data set:
global check_vars dyadkey tietype recent local2 race2 ethn2 sex2 orient2 occpres2 occcens2 pro2 pimp2 john2 dealer2 drugman2 thief2 ///
				  unemp2 streets2 educ2 gono2 gonoev2 chlam2 chlamev2 syph2 syphev2 hiv hiv2 hbv2 gonohx2 chlamhx2 syphhx2 hivhx1 ///
				  hivhx2 freq occ2 
/*
foreach var in $check_vars{
    codebook `var'
	}
*/

keep id1 id2  ntype1 studynum intdate dyadkey tietype recent race1 race2 ethn1 ethn2 sex1 sex2 occpres2 occcens2 educ2 occ2 

* Dropping the Canadian settings:
drop if studynum == 8

* Checking for information:
bys studynum: tab race1 	/**/
bys studynum: tab ethn1 	/*Idem*/
bys studynum: tab sex1  	/*All right*/
bys studynum: tab race2 	/*Baltimore does not seem to have this information*/
bys studynum: tab ethn2 	/*Idem*/
bys studynum: tab sex2  	/*All right*/
bys studynum: sum occpres2  /*Only Colorado Springs has this information*/
bys studynum: tab occcens2  /*Idem*/
bys studynum: tab educ2 	/*None seem to have much of this information*/
bys studynum: tab occ2 		/*Idem*/ 
bys studynum: tab recent 	/*Idem*/

* Dropping variables with too much missing values:
drop occ* educ
				  
/* Remarks:
* 1) OOD: "out of the distribution"-seem to be answers that are extremely unlikely to be true so they were removed by the research team
  2) Tie type seems not to have been asked in one study. We will check that
*/				  

* Creating date variable:
gen int_year = substr(intdate, -4, .)
gen int_month = substr(intdate, -8, 3)
gen dropme = cond(int_month == "Jan", "01", ///
				 cond(int_month == "Feb", "02", ///
				 cond(int_month == "Mar", "03", ///
				 cond(int_month == "Apr", "04", ///
				 cond(int_month == "May", "05", ///
				 cond(int_month == "Jun", "06", ///
				 cond(int_month == "Jul", "07", ///
				 cond(int_month == "Aug", "08", ///
				 cond(int_month == "Sep", "09", ///
				 cond(int_month == "Oct", "10", ///
				 cond(int_month == "Nov", "11", "12" ///
			 )))))))))))
	
gen dropme2 = int_year + "-" + dropme
gen date = date(dropme2, "YM")
format date %tm
drop dropme*

* Keeping only study respondents:
keep if ntype1 == 1

* Identifying unique observations in each study:

* First: Colorado Springs:
preserve 
	keep if studynum == 1

	duplicates report id1 id2 date tietype 
	* Observations: tie-types. A tie can appear more than once depending on how many times the ego node was interviews + 
	* how many different types of relationships the person shares with the alter
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race1 ethn1 sex1 race2 ethn2 sex2
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/colorado_springs.dta", replace
restore

* 2) Atlanta:
preserve
	keep if studynum == 3
	
	duplicates report id1 id2 date tietype 
	
	duplicates report id1 id2 date tietype recent
	
	* Observations: tie-types-frequency. For some reason we can have more than one frequency of interaction per tie-type-date 

	duplicates tag id1 id2 date tietype, gen(duplicates)
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race1 ethn1 sex1 race2 ethn2 sex2
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/atlanta_urban.dta", replace
restore

*3) Flagstaff rural:	
preserve
	keep if studynum == 4
	
	duplicates report id1 id2 date tietype 
	
	duplicates report id1 id2 date tietype recent
	
	* Observations: tie-types-frequency. For some reason we can have more than one frequency of interaction per tie-type-date 

	duplicates tag id1 id2 date tietype, gen(duplicates)
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race2 ethn2 sex2 race1 ethn1 sex1
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/flagstaff_rural.dta", replace
restore

*4) Atlanta antiviral:	
preserve
	keep if studynum == 5
	
	duplicates report id1 id2 date tietype 
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
		sum 
		
		global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
						recent_interac_needle race2 ethn2 sex2 race1 ethn1 sex1
		
		foreach var in $tie_vars{
			tab `var'
		}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/atlanta_antiviral.dta", replace
restore

*5) Houston:	
preserve
	keep if studynum == 6
	
	duplicates report id1 id2 date tietype 
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race2 ethn2 sex2 race1 ethn1 sex1
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/houston.dta", replace
restore

*6) Baltimore:	
preserve
	keep if studynum == 7
	
	duplicates report id1 id2 date tietype 
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race2 ethn2 sex2 race1 ethn1 sex1
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/baltimore.dta", replace
restore

*7) Bushwick (Brooklyn)
preserve
	keep if studynum == 2
	
	duplicates report id1 id2 date tietype 
	
	* Generate tie-related variables:
	gen tie_social = tietype == 1
	gen tie_drug = (tietype == 2 | tietype == 4)
	gen tie_sexual = tietype == 3
	gen tie_needle = tietype == 4
	
	gen recent_interac_social = (tie_social == 1 & recent == 1)
	gen recent_interac_drug = (tie_drug == 1 & recent == 1)
	gen recent_interac_sexual = (tie_sexual == 1 & recent == 1)
	gen recent_interac_needle = (tie_needle == 1 & recent == 1)
	
	*Aggregate to have one row per tie:
	collapse (sum) tie_social tie_sexual tie_needle recent_interac_sexual recent_interac_social recent_interac_needle ///
			 (mean) tie_drug recent_interac_drug race1 ethn1 sex1 race2 ethn2 sex2, by(id1 id2 date studynum)
	
	*Sanity check: kept one observation per tie
	sort id1 id2 date
	by id1 id2: gen dropme = _n
	
	keep if dropme == 1
	
	duplicates report id1 id2 /*Good!*/
	
	* Sanity check: variable values:
	sum 
	
	global tie_vars tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug recent_interac_sexual ///
					recent_interac_needle race2 ethn2 sex2 race1 ethn1 sex1
	
	foreach var in $tie_vars{
		tab `var'
	}
	* Few observations with missing values
	
	* Saving database:
	save "$path_aux/brooklyn.dta", replace
restore

* Merging setting databases:
use "$path_aux/colorado_springs.dta", clear

global settings "atlanta_urban flagstaff_rural atlanta_antiviral houston baltimore brooklyn"

foreach var in $settings{
	merge 1:1 studynum id1 id2 date using "$path_aux/`var'.dta"
	drop _merge
	}

* Generating additional variables:
gen ego_female = sex1 == 1
gen alter_female = sex2 == 1

gen ego_ethnicity  = cond(race1 == 2 & ethn1 == 0, 0, /// 
					 cond(ethn1 == 1, 1, ///
					 cond(race1 == 4 & ethn1 == 0, 2, 3)))
					 
gen network_size = 1
					 
* Generating ego-network base:
collapse  (mean) ego_female ego_ethnicity tie_social tie_drug tie_sexual tie_needle recent_interac_social recent_interac_drug ///
				 recent_interac_sexual recent_interac_needle ///
		   (sum)  network_size, ///
			by   (id1 studynum)

* Keep only ego-nodes that are drug users (those with at least 1 drug-related tie)
keep if tie_drug > 0
			
* Checks:
tab ego_female     /*two cases of people coded erroneously in a tie*/
tab ego_ethnicity  /*idem*/

sum tie_* recent_* network_size, d

tab studynum

gen aux = cond(ego_ethnicity == 0, "Black", /// 
		  cond(ego_ethnicity == 1, "Hispanic", ///
		  cond(ego_ethnicity == 2, "White", "Others")))
			 
drop ego_ethnicity
rename aux ego_ethnicity


gen aux = cond(ego_female == 0, "Male", "Female")
drop ego_female
rename aux ego_female


gen aux = cond(studynum == 1, "Colorado Springs", /// 
		  cond(studynum == 2, "Brooklyn", ///
		  cond(studynum == 3, "Atlanta (Urban)", /// 
		  cond(studynum == 4, "Flagstaff (Arizona)", ///
		  cond(studynum == 5, "Atlanta (Antiviral)", ///
		  cond(studynum == 6, "Houston", "Baltimore"))))))
			 
drop studynum
rename aux studynum

* Saving:
save "$path_outputs/ego_network.dta", replace