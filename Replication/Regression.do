

* FIGURE 1 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT, ready.dta", clear 


* 'We remove extremely small funds (those with assets < $6M in 1980)' 
egen below = total(assets < 6000 & year == 1980), by(wficn)
drop if below > 0	// about 3K out of 57K deleted 

drop if year == 2018 

*********** 
xtile expense_decile = exp_ratio, nq(10)
sort expense_decile

egen mean_profitability = mean(w_profitability), by(expense_decile) 
twoway (connected mean_profitability expense_decile, lcolor(blue) lwidth(medium)) 	// opposite trend :(   

egen mean_age_c = mean(age_c), by(expense_decile) 
twoway (connected mean_age_c expense_decile, lcolor(blue) lwidth(medium)) 	// looks VERY good

egen mean_assetGrowth = mean(w_AssetGrowth), by(expense_decile) 
twoway (connected mean_assetGrowth expense_decile, lcolor(blue) lwidth(medium)) 	// looks good

egen mean_Sharegrowth = mean(w_Sharegrowth), by(expense_decile) 
twoway (connected mean_Sharegrowth expense_decile, lcolor(blue) lwidth(medium)) 	// flat  



* TABLE 2 // ONLY RESULTS FOR ASSET GROWTH & SHARE GROWTH ARE CONSISTENT, THE REST IS OPPOSITE SIGN  

// merge to get Lipper code (for FE) 
merge m:1 wficn year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\lipper_unique.dta", keepusing(lipper_class_name) 	// 730K out of 930K matched 
keep if _merge == 3
drop _merge 

encode lipper, gen(lipper_num)

reghdfe log_w_profitability log_exp_ratio log_fund_age log_family_size log_mtna_class_sum, a(year wficn) vce(cluster wficn year)  // fund_age is omitted because collinearity with FE   
reghdfe log_w_profitability log_exp_ratio log_family_size log_fund_age log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year)  // opposite sign again! 
reghdfe scaled_w_profitability scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)  // opposite sign and extremely high t-statistics   


reghdfe log_w_age_c log_exp_ratio log_family_size log_fund_age log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year) 	// opposite sign (STRANGE!)  
reghdfe scaled_w_agec scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)  // opposite sign and extremely high t-statistics   

reghdfe log_w_BM log_exp_ratio log_family_size log_fund_age log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year) 	// opposite sign (STRANGE!)  
reghdfe scaled_w_BM scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // opposite sign and extremely high t-statistics 

reghdfe log_w_size log_exp_ratio log_family_size log_fund_age log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year) 	// opposite sign (STRANGE!)  
reghdfe scaled_w_size scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // opposite sign and extremely high t-statistics 

reghdfe log_w_AssetGrowth log_exp_ratio log_family_size log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year) 	// BUT SO GOOD RESULT FOR THIS!  
reghdfe scaled_w_AssetGrowth scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // extremely high t-statistics 

reghdfe log_w_Sharegrowth log_exp_ratio log_family_size log_mtna_class_sum, a(lipper_num##year) vce(cluster wficn year) 	// BUT SO GOOD RESULT FOR THIS!  
reghdfe scaled_w_Sharegrowth scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // extremely high t-statistics 


*** EXTENSION: Positive & significant: high-fee funds managers also til towards Innovation-driven firms (R&D Expenses and CapEx)  
reghdfe scaled_w_RD scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // extremely high t-statistics 

reghdfe scaled_w_CapEx scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)   // extremely high t-statistics 


*** FIGURE 3 
* FF5 shows that high-fee funds managers can exploit higher alpha*

use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\SECOND PART, ready", clear 

xtile expense_decile = exp_ratio, nq(10)

* Step 2: Calculate the average alpha for each decile and each model
collapse (mean) gAlpha_CAPM gAlpha_FF3 gAlpha_FF4 gAlpha_FF5 nAlpha_CAPM nAlpha_FF3 nAlpha_FF4 nAlpha_FF5, by(expense_decile)

* Before-fee alpha 
twoway (line gAlpha_CAPM expense_decile, m(o) lc(gs14) lw(med) lpattern(dash)) ///
       (line gAlpha_FF3 expense_decile, m(T) lc(gs12) lw(med) lpattern(dash_dot)) ///
       (line gAlpha_FF4 expense_decile, m(i) lc(black) lw(med) lpattern(solid)) ///
       (line gAlpha_FF5 expense_decile, m(i) lc(red) lw(med) lpattern(longdash)), ///
       legend(label(1 "CAPM") label(2 "Fama-French 3 Factor") ///
              label(3 "Fama-French-Carhart 4 Factor") label(4 "Fama-French 5 Factor")) ///
       xtitle("Expense Ratio Decile") ytitle("Alpha percent per year")

* After-fee alpha 	   
twoway (line nAlpha_CAPM expense_decile, m(o) lc(gs14) lw(med) lpattern(dash)) ///
       (line nAlpha_FF3 expense_decile, m(T) lc(gs12) lw(med) lpattern(dash_dot)) ///
       (line nAlpha_FF4 expense_decile, m(i) lc(black) lw(med) lpattern(solid)) ///
       (line nAlpha_FF5 expense_decile, m(i) lc(red) lw(med) lpattern(longdash)), ///
       legend(label(1 "CAPM") label(2 "Fama-French 3 Factor") ///
              label(3 "Fama-French-Carhart 4 Factor") label(4 "Fama-French 5 Factor")) ///
       xtitle("Expense Ratio Decile") ytitle("Alpha percent per year")



	  
* TABLE 3 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\SECOND PART, ready", clear 
 

// merge to get Lipper code (for FE) 
merge m:1 wficn year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\lipper_unique.dta", keepusing(lipper_class_name) 	// 730K out of 930K matched 
keep if _merge == 3
drop _merge 


// 
merge m:1 wficn year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT, ready.dta", keepusing(assets size family_size fund_age) 	// 639K out of 923K merged 
keep if _merge == 3
drop _merge 

* "We remove extremely small funds (those with assets < $6M in 1980)" 
egen below = total(assets < 6000 & year == 1980), by(wficn)
drop if below > 0	// about 3K out of 57K deleted 

drop if year == 2018



rename lipper_class_name lipper 

winsor2 exp_ratio, cuts(1 99) replace 
winsor2 size, cuts(1 99) replace 
winsor2 family_size, cuts(1 99) replace 

gen log_expense = log(exp_ratio) 
gen log_size = log(size) 
gen log_familysize = log(family_size) 
gen log_fund_dage = log(fund_age) 

egen std_expense = std(exp_ratio) 
egen std_size = std(size) 
egen std_familysize = std(family_size) 
egen std_fund_age = std(fund_age)  
egen std_nAlpha_FF5 = std(nAlpha_FF5) 

encode lipper, gen(lipper_num)


************************** 
* alternative (but make some sense) results: FF5 is better at explaining alpha captured by high-fee fund managers than the other three models 	 
reghdfe gAlpha_FF5 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF4 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF3 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_CAPM std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 	// not significant! GOOD! 

* alternative results: expenses are not related to fees for all models, not just FF5 
reghdfe nAlpha_FF5 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe nAlpha_FF4 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe nAlpha_FF3 std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
reghdfe nAlpha_CAPM std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 
*********************************************** 


*** TABLE 4 
egen std_FF5_cma = std(FF5_cma) 
egen std_FF5_rmw = std(FF5_rmw) 
egen std_FF5_market = std(FF5_market) 
egen std_FF5_hml = std(FF5_hml) 
egen std_FF5_smb = std(FF5_smb) 

reghdfe std_FF5_cma std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 	// opposite results 
reghdfe std_FF5_rmw std_expense std_size std_fund_age std_familysize, a(lipper_num##month) vce(cluster wficn month) 	// same sign but not significant  

reghdfe std_FF5_cma std_expense std_size std_fund_age std_familysize std_FF5_market std_FF5_hml std_FF5_smb, a(lipper_num##month) vce(cluster wficn month) 	// opposite sign and not significant  
reghdfe std_FF5_rmw std_expense std_size std_fund_age std_familysize std_FF5_market std_FF5_hml std_FF5_smb, a(lipper_num##month) vce(cluster wficn month) 	// opposite sign and not significant




*** TABLE 5 (GOOD TABLE BY FAR!) 

* Fund size (same sign and significant)  
egen median_fund_size = median(std_size)
gen aboveM_fund_size = std_size > median_fund_size	// Dummy = 1 if > median 

reghdfe gAlpha_FF5 std_expense if aboveM_fund_size == 1, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF5 std_expense if aboveM_fund_size == 0, a(lipper_num##month) vce(cluster wficn month) 

* Fund age (same sign and significant)  
egen median_fund_age = median(std_fund_age)
gen aboveM_fund_age = std_fund_age > median_fund_age	// Dummy = 1 if > median 

reghdfe gAlpha_FF5 std_expense if aboveM_fund_age == 1, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF5 std_expense if aboveM_fund_age == 0, a(lipper_num##month) vce(cluster wficn month) 

* Family size (same sign and significant)  
egen median_family_size = median(std_familysize)
gen aboveM_family_size = std_familysize > median_family_size	// Dummy = 1 if > median 

reghdfe gAlpha_FF5 std_expense if aboveM_family_size == 1, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF5 std_expense if aboveM_family_size == 0, a(lipper_num##month) vce(cluster wficn month)

* Turnover ratio (same sign and significant)  
egen scaled_turn_ratio = std(turn_ratio) 
egen median_turn_ratio = median(scaled_turn_ratio)
gen aboveM_turn_ratio = scaled_turn_ratio > median_turn_ratio	// Dummy = 1 if > median 

reghdfe gAlpha_FF5 std_expense if aboveM_turn_ratio == 1, a(lipper_num##month) vce(cluster wficn month) 
reghdfe gAlpha_FF5 std_expense if aboveM_turn_ratio == 0, a(lipper_num##month) vce(cluster wficn month)



*** TABLE 7 (middle column - Tangibility) 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT, ready.dta", clear 

* 'We remove extremely small funds (those with assets < $6M in 1980)' 
egen below = total(assets < 6000 & year == 1980), by(wficn)
drop if below > 0	// about 3K out of 57K deleted 

drop if year == 2018 

// merge to get Lipper code (for FE) 
merge m:1 wficn year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\lipper_unique.dta", keepusing(lipper_class_name) 	// 52K out of 80K matched  
keep if _merge == 3
drop _merge 

encode lipper, gen(lipper_num)

// 
egen scaled_w_tangibility = std(w_tangibility) 
gen management_fee = exp_ratio - actual_12b1 
egen scaled_management_fee = std(management_fee)

reghdfe scaled_w_tangibility scaled_exp_ratio scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)  // opposite sign and extremely high t-statistics   

reghdfe scaled_w_tangibility scaled_management_fee scaled_family_size scaled_fund_age scaled_ClassSize, a(lipper_num##year) vce(cluster wficn year)  // opposite sign and extremely high t-statistics   









