clear all

global root "C:\Users\jhony\Google Drive\Universidades\University of Chicago\Courses\3. Spring Quarter\Social Network Analysis\Final project\Paper\Data"

global path_inputs  "$root\1_Inputs"
global path_aux 	"$root\2_Aux"
global path_outputs	"$root\3_Outputs"

* Generating a database with the ids of the study's participants
use "$path_outputs/ego_network.dta", clear

keep id1 studynum

rename id1 id2

save "$path_aux/ids_participants.dta", replace

use "$path_inputs/22140-0002-Data.dta", clear

* First, keep only drug ties
keep if tietype == 2 | tietype == 4

keep id1 id2 studynum

gen aux = cond(studynum == 1, "Colorado Springs", /// 
		  cond(studynum == 2, "Brooklyn", ///
		  cond(studynum == 3, "Atlanta (Urban)", /// 
		  cond(studynum == 4, "Flagstaff (Arizona)", ///
		  cond(studynum == 5, "Atlanta (Antiviral)", ///
		  cond(studynum == 6, "Houston", "Baltimore"))))))
			 
drop studynum
rename aux studynum

* Now, keep ties whose alter nodes are participants:
merge m:1 id2 studynum using  "$path_aux/ids_participants.dta"
keep if _merge==3

drop _merge

* Keep if ego-node is a participant:
merge m:1 id1 studynum using  "$path_outputs/ego_network.dta"

drop if _merge == 1

* _merge == 2 : ego-nodes without ties with other ego nodes. They will be treate as isolates

gen isolate = _merge == 2

drop _merge 
/*
* Then, keep only participants that are drug users:
merge m:1 id1 studynum using  "$path_outputs/ego_network.dta"
keep if _merge == 3
drop _merge


* _merge == 1 : ties between an ego-node and an alter node that is not a direct participant

* _merge == 3 : ties between ego-nodes 

gen ego_tie = _merge==3

bys studynum id1: egen has_ego_tie = max(ego_tie)

bys studynum id1: gen dropme = _n if has_ego_tie ==0

keep if has_ego_tie == 1 | dropme ==1

replace id2 = . if dropme==1

drop _merge dropme

merge m:1 id2 studynum using  "$path_aux/ids_participants.dta"
*/
save "$path_outputs/whole_network.dta", replace
