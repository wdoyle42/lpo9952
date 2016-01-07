version 12 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */


  log using "conditional_means.log",replace /*Open up new log */

/* Conditional Means*/
/* Making the link between conditional means and regression */
/* Will Doyle */
/* 160107 */
/* Practicum Folder */

clear matrix

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */ 

set scheme s1color /* My  preferred graphics scheme */

graph drop _all    

/*Graphics Type*/
local gtype pdf

/*Load dataset*/
use ../data/plans

/*Locals for analysis*/
local y fouryr

local test bynels2m bynels2r

local race amind asian black hispanic multiracial

local pared bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd 

local income byses1

/**************************************************/
/* Outline */
/**************************************************/

/*Coding    */

local coding=1
    
/**************************************************/


/**************************************************/
/* Coding */
/**************************************************/
    
if `coding'==1{

  use plans, clear

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

local race_names amind asian black hispanic_no hispanic_race multiracial white

tab(byrace), gen(race_)

local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable white "White"
label variable multiracial "Multiracial"


gen hispanic=0
replace hispanic=1 if hispanic_no==1|hispanic_race==1
replace hispanic=. if byrace==.

label variable hispanic "Hispanic"

local plan_names noplan dontknow votech cc fouryr earlygrad

recode byrace (4/5=4) (6=5) (7=6) (.=.), gen(byrace2)

label define byrace2 1 "Am.Ind." 2 "Asian/PI" 3 "Black" 4 "Hispanic" 5 "Multiracial" 6 "White"

label values byrace2 byrace2


gen urm=.
replace urm=0 if byrace2==4 | byrace2==6
replace urm=1 if byrace2==1 | byrace2==2 | byrace2==3 | byrace2==5
  
tab(f1psepln), gen(plan_)

local i=1

foreach val of local plan_names{
  rename plan_`i' `val'
  local i=`i'+1
}


label variable noplan "Plans: No plans"
label variable dontknow "Plans: Don't know"
label variable votech "Plans: Voc/Tech School"
label variable cc "Plans: Comm Coll"
label variable fouryr "Four Year"
label variable earlygrad "Early Graduation"

/* Plans for those who have them */

gen order_plan=.
replace order_plan=1 if noplan==1| dontknow==1
  replace order_plan=2 if votech==1|cc==1
  replace order_plan=3 if fouryr==1

label define orderplan 1 "No Plans/DK" 2 "Votech/CC" 3 "Four Year"

label values order_plan orderplan
  
local pareds bymothed byfathed bypared

local ed_names nohs hs 2yrnodeg 2yr some4  4yrgrad masters phd

foreach pared of local pareds{

tab(`pared'), gen(`pared'_)

local i=1

foreach val of local ed_names{
  rename `pared'_`i' `pared'_`val'
  local i=`i'+1
}

label variable `pared'_nohs "Less than HS"
label variable `pared'_hs "HS/GED"
label variable `pared'_2yr "CC" 
label variable `pared'_some4 "Four year attend"
label variable `pared'_4yrgrad "Bachelor's"
label variable `pared'_masters "Master's"
label variable `pared'_phd "PhD"
}

label define expect -1 "Don't Know" 1 "Less than HS" 2 "HS" 3 "2 yr" 4 "4 yr No Deg" ///
    5 "Bachelors" 6 "Masters" 7 "Advanced"

label values bystexp expect
  
tab bystexp,gen(exp_)

gen female=bysex==2
replace female=. if bysex==.

lab var female "Female"

replace bynels2m=bynels2m/100

replace bynels2r=bynels2r/100  
  
recode f2ps1sec (1=1) (2=2) (4=3) (3=4) (5/9=4), gen(first_inst)

label define sector 1 "Public 4 Year" 2 "Private 4 Year" 3 "Public 2 Year"  4 "Other"

label values first_inst sector
   
lab var bynels2m "10th Grade Math Scores"
lab var bynels2r "10th Grade Reading Scores"
lab var byses1 "SES v1"
lab var byses2 "SES v2"

save plans2, replace

}/*End coding section */

else use plans2, clear

/**************************************************/
    
/**************************************************/
/*Analysis*/
/**************************************************/

 //Using the mean as a prediction

sort byses1

graph twoway scatter bynels2m byses1, msize(vtiny)

egen uncond_mean=mean(bynels2m)

gen uncond_mean_error=bynels2m-uncond_mean

gen uncond_mean_error_sq=uncond_mean_error*uncond_mean_error

quietly sum uncond_mean_error_sq

scalar uncond_mean_mse=r(mean)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) (line uncond_mean byses1,lcolor(blue)), legend(order(2 "Unconditional Mean"))

// Above average(median) vs. below average 

egen sesq2=cut(byses1), group(2)

egen cond_mean2=mean(bynels2m), by(sesq2)

gen cond_mean2_error=bynels2m-cond_mean2

gen cond_mean2_error_sq=cond_mean2_error*cond_mean2_error

quietly sum cond_mean2_error_sq

scalar cond_mean2_mse=r(mean)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)), ///
              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups") )

// Using quartiles as the basis for predictions

egen sesq4=cut(byses1), group(4)

egen cond_mean4=mean(bynels2m), by(sesq4)

gen cond_mean4_error=bynels2m-cond_mean4

gen cond_mean4_error_sq=cond_mean4_error*cond_mean2_error

quietly sum cond_mean4_error_sq

scalar cond_mean4_mse=r(mean)

scalar li

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)) ///
             (line cond_mean4 byses1,lcolor(yellow)), ///    
             legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups" 4 "Conditional Mean, 4 Groups") )


// Regression

reg bynels2m byses1

predict reg_predict

predict reg_error, residual

gen reg_error_sq=reg_error*reg_error

quietly sum reg_error_sq

scalar reg_mse=r(mean)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)) ///
             (line cond_mean4 byses1,lcolor(yellow)) ///
             (line reg_predict byses1,lcolor(red)), ///        
             legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups" 4 "Conditional Mean, 4 Groups" 5 "Regression Prediction") )


scalar li

//End




