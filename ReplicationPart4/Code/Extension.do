/*
BeliefPrSs:  Reported Belief of the Probability of a Success conditional on observing a positive test result

BeliefPrSf:  Reported Belief of the Probability of a Success conditional on observing a negative test result

Treatment: 0: NP, 1: P, 2: NP w/lock in, 3: P w/lock in, 4: P w/shock, 5: NP w/freq., 6: NP w/freq. 

Major:       STEM-related major (1:Yes)
*/

////////////////////////////////////
/*
Table 4: Average Distance to Bayesian Benchmark in Primitives vs. NoPrimitives
*/
////////////////////////////////////

cls
use "/Users/ikingary/Desktop/UCSD/COMPU/ReplicationProject/ReplicationPart4/data/data.dta", replace

qui gen dtobay_pos = abs(BeliefPrSs - 41)
qui gen dtobay_neg = abs(BeliefPrSf - 4)
qui gen aggdist = dtobay_pos + dtobay_neg

*Generating Demographic variables. In the initial data set demographic variables are collected at the end of the session. 
*This creates a demographic variable per participant so that it can be connected to earlier choices in a session

foreach i in ProbClass Major Gender_F {
qui gen junk=`i' if `i'>0
qui bysort i: egen `i'_Agg=mean(junk)
drop junk
qui replace `i'=`i'_Agg
drop `i'_Agg
}

foreach i in ProbClass Major Gender_F {
qui replace `i'=0 if `i'!=1
}
qui ren Major Major_STEM


qui keep if Part==3|Part==4
qui gen prim = (Treatment ==1 | Treatment == 6 | Treatment ==3)
qui gen freq = Treatment > 4
qui gen shock = Treatment ==4
qui gen lockin = (Treatment ==2 | Treatment == 3)

qui replace BeliefPrSs = dtobay_pos
qui replace BeliefPrSf = dtobay_neg

* Generate interaction term between Gender_F and Major_STEM
gen Gender_STEM = Gender_F * Major_STEM

* Round 200
eststo clear
eststo: sureg (BeliefPrSs prim Gender_F Major_STEM Gender_STEM)(BeliefPrSf prim Gender_F Major_STEM Gender_STEM) if (Treatment ==0 | Treatment ==1) & Round ==1
*p value for conditional on positive signal and negative signal with survey controls and interaction term
estout, cells(p(fmt(3))) drop(_cons) unstack
*p value for H0 P=NP with interaction term
test Gender_STEM




