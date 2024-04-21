

*** SECOND PART: 
* FIGURE 3, TABLE 3, TABLE 4, TABLE 5 


*** "A fund's alpha in month t is the difference between the fund's excess return in month t and its benchmark return, calculated as the sum of the products of factor returns in t and factor loadings estimated from rolling regressions on 5 years of monthly data." 


use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", clear 

*** 5-year ROLLING 

* Sort and set the dataset
sort wficn ym
xtset wficn ym



**************************************************
*** CAPM  
generate alpha_CAPM = .

* Perform rolling regressions and handle outputs
levelsof wficn, local(funds)
foreach fund in `funds' {
    * Use 'rolling' command directly with the active dataset
    rolling _b, window(60) step(1) saving("${fund}_rolling", replace): ///
        regress gret mktrf if wficn == `fund'
    
    * Use the rolled data
    use "${fund}_rolling", clear
    sort ym
    merge 1:1 ym using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", assert(match master) keepusing(gret mktrf)

    * Calculate expected returns and alpha
    generate expected_return = _b_mktrf*mktrf  
    replace alpha_CAPM = gret - expected_return

    * Save the results for this fund
    save "${fund}_alpha", replace
}

egen beta_mktrf = mean(_b_mktrf)	// = 0.9135807  






**************************************************
*** FF3 
generate alpha_FF3 = .

* Perform rolling regressions and handle outputs
levelsof wficn, local(funds)
foreach fund in `funds' {
    * Use 'rolling' command directly with the active dataset
    rolling _b, window(60) step(1) saving("${fund}_rolling", replace): ///
        regress gret mktrf smb hml if wficn == `fund'
    
    * Use the rolled data
    use "${fund}_rolling", clear
    sort ym
    merge 1:1 ym using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", assert(match master) keepusing(gret mktrf smb hml)

    * Calculate expected returns and alpha
    generate expected_return = _b_mktrf*mktrf + _b_smb*smb + _b_hml*hml 
    replace alpha_FF3 = gret - expected_return

    * Save the results for this fund
    save "${fund}_alpha", replace
}


egen beta_mktrf = mean(_b_mktrf)	// = 0.94357276  
egen beta_smb = mean(_b_smb)		// = -0.1803878    
egen beta_hml = mean(_b_hml)		// = -0.0015409   




**************************************************
*** FF4 
generate alpha_FF4 = .

* Perform rolling regressions and handle outputs
levelsof wficn, local(funds)
foreach fund in `funds' {
    * Use 'rolling' command directly with the active dataset
    rolling _b, window(60) step(1) saving("${fund}_rolling", replace): ///
        regress gret mktrf smb hml umd if wficn == `fund'
    
    * Use the rolled data
    use "${fund}_rolling", clear
    sort ym
    merge 1:1 ym using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", assert(match master) keepusing(gret mktrf smb hml umd)

    * Calculate expected returns and alpha
    generate expected_return = _b_mktrf*mktrf + _b_smb*smb + _b_hml*hml + _b_umd*umd
    replace alpha_FF4 = gret - expected_return

    * Save the results for this fund
    save "${fund}_alpha", replace
}


egen beta_mktrf = mean(_b_mktrf)	// = 0.94529945 
egen beta_smb = mean(_b_smb)		// = -0.1817569   
egen beta_hml = mean(_b_hml)		// = -0.0076383  
egen beta_umd = mean(_b_umd)		// = -0.0067068  



**********************************************************************


*** FF5 
generate alpha_FF5 = .

* Perform rolling regressions and handle outputs
levelsof wficn, local(funds)
foreach fund in `funds' {
    * Use 'rolling' command directly with the active dataset
    rolling _b, window(60) step(1) saving("${fund}_rolling", replace): ///
        regress gret mktrf smb hml rmw cma if wficn == `fund'
    
    * Use the rolled data
    use "${fund}_rolling", clear
    sort ym
    merge 1:1 ym using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", assert(match master) keepusing(gret mktrf smb hml rmw cma)

    * Calculate expected returns and alpha
    generate expected_return = _b_mktrf*mktrf + _b_smb*smb + _b_hml*hml + _b_rmw*rmw + _b_cma*cma
    replace alpha_FF5 = gret - expected_return

    * Save the results for this fund
    save "${fund}_alpha", replace
}


egen beta_mktrf = mean(_b_mktrf)	// = 0.9524867 
egen beta_smb = mean(_b_smb)		// = -0.1678147  
egen beta_hml = mean(_b_hml)		// = -0.187651 
egen beta_rmw = mean(_b_rmw)		// = 0.0289906 
egen beta_cma = mean(_b_cma)		// = -0.0224786 

**********************************************************************




*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", clear 

*** AVERAGE 
** FF5 
* OLS to calculate Beta for each factor
regress gret mktrf smb hml rmw cma

gen expected_return_FF5 = 0.9524867*mktrf + -0.1678147*smb + -0.187651*hml + 0.0289906*rmw + -0.0224786*cma 
// gen expected_return_FF5 = beta_mktrf*mktrf + beta_smb*smb + beta_hml*hml + beta_rmw*rmw + beta_cma*cma

gen gAlpha_FF5 = gret - expected_return_FF5
gen nAlpha_FF5 = mret - expected_return_FF5



** FF4 
* OLS to calculate Beta for each factor
regress gret mktrf smb hml umd 

* This ensures the local macros are used within their scope
gen expected_return_FF4 = 0.94529945*mktrf + -0.1817569*smb + -0.0076383*hml + -0.0067068*umd 
gen gAlpha_FF4 = gret - expected_return_FF4
gen nAlpha_FF4 = mret - expected_return_FF4





** FF3  
* OLS to calculate Beta for each factor
regress gret mktrf smb hml 

gen expected_return_FF3 = 0.94357276*mktrf + -0.1803878*smb + -0.0015409*hml 
gen gAlpha_FF3 = gret - expected_return_FF3 
gen nAlpha_FF3 = mret - expected_return_FF3 



** CAPM   
* OLS to calculate Beta for each factor
regress gret mktrf 

gen expected_return_CAPM = 0.9135807*mktrf 
gen gAlpha_CAPM = gret - expected_return_CAPM  
gen nAlpha_CAPM = mret - expected_return_CAPM 


*** 
drop expected_return_FF5 expected_return_FF4 expected_return_FF3 expected_return_CAPM 


*** 
g FF5_market = 0.9524867*mktrf 
g FF5_hml = -0.187651*hml 
g FF5_smb = -0.1678147*smb
g FF5_cma = 0.0289906*cma 
g FF5_rmw = -0.0224786*rmw


save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\SECOND PART, ready" 




*** FIRST PART: 
* TABLE 2, FIGURE 1, FIGURE 2 (Panel name: FIRST PART) 

* holdings2 + compa, position-weighted average all stocks by each fund, then merge with fund_monthly

use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT.dta", clear 


* CONSTRUCT MAIN VARIABLES 
drop if missing(bkvlps) 	// only 86K out of 12.8M observations deleted 
 
g BM = bkvlps*csho 
rename mkvalt size 

// cannot xtset panel, so use R&D, CapEx, and PPE to proxy for Asset growth instead 
rename xrd RD 
rename capx CapEx 
rename ppegt PPE 

rename cshi EquityIssuance 		// cannot xtset the panel, so use Common Shares Issued to proxy 

drop if BM == 0 
foreach var in revt cogs xsga tie BM {
    replace `var' = 0 if missing(`var')
} 	// because any missing value in this calculation with result in missing output 
g profitability = (revt-cogs-xsga-tie)/BM 

g age = ipo_year - year 	// half of the panel don't have information on ipo_year 
g age_c = abs(age) 
 
egen fund_age = max(age_c), by(wficn)


* WEIGHTED 
* Collapse to fund-year level (sum up share values of each fund's stockholdings, position-weighted average by stock holdings in each fund-year) 
g PricePerShare = size/csho 
g value = shares * PricePerShare
egen fund_stockholdings = sum(value), by(wficn year)
gen weight = value/fund_stockholdings 

// 
egen family_size = sum(value), by(mgmt_cd year) // Construct fund family size


// Scaling 
gen w_BM = BM*weight 
gen w_size = size*weight 
gen w_RD = RD*weight 
gen w_CapEx = CapEx*weight 
gen w_PPE = PPE*weight 
gen w_EquityIssuance = EquityIssuance*weight 
gen w_revt = revt*weight 
gen w_cogs = cogs*weight 
gen w_xsga = xsga*weight 
gen w_profitability = profitability*weight 
gen w_agec = age_c*weight
gen w_AssetGrowth = asset_growth*weight
gen w_Sharegrowth = Share_growth*weight 

g tangibility = PPE/at 
gen w_tangibility = tangibility*weight 
gen w_at = at*weight 


* Winsor 1 and 99 percentile 
winsor2 w_BM, cuts(1 99) replace 
winsor2 w_size, cuts(1 99) replace 
winsor2 w_RD, cuts(1 99) replace 
winsor2 w_CapEx, cuts(1 99) replace 
winsor2 w_PPE, cuts(1 99) replace 
winsor2 w_EquityIssuance, cuts(1 99) replace 
winsor2 w_revt, cuts(1 99) replace 
winsor2 w_cogs, cuts(1 99) replace 
winsor2 w_xsga, cuts(1 99) replace 
winsor2 w_profitability, cuts(1 99) replace 
winsor2 w_agec, cuts(1 99) replace 
winsor2 w_AssetGrowth, cuts(1 99) replace 
winsor2 w_Sharegrowth, cuts(1 99) replace 
winsor2 w_tangibility, cuts(1 99) replace 
winsor2 w_at, cuts(1 99) replace 

winsor2 exp_ratio, cuts(1 99) replace 
winsor2 assets, cuts(1 99) replace 
winsor2 mtna_class_sum, cuts(1 99) replace 
winsor2 family_size, cuts(1 99) replace 
winsor2 actual_12b1, cuts(1 99) replace 
winsor2 turn_ratio, cuts(1 99) replace 

 
collapse (mean) turn_ratio actual_12b1 fund_age tangibility at w_tangibility w_at BM size RD CapEx PPE EquityIssuance revt cogs xsga profitability age_c asset_growth Share_growth w_BM w_size w_RD w_CapEx w_PPE w_EquityIssuance w_revt w_cogs w_xsga w_profitability w_agec w_AssetGrowth w_Sharegrowth exp_ratio assets mtna_class_sum family_size, by(wficn year) 	// have 57.4K observations 


***
*** 'We standardized all variables for ease of interpretation of magnitudes of coefficients' 
egen scaled_w_BM = std(w_BM) 
egen scaled_w_size = std(w_size) 
egen scaled_w_RD = std(w_RD) 
egen scaled_w_CapEx = std(w_CapEx) 
egen scaled_w_PPE = std(w_PPE) 
egen scaled_w_EquityIssuance = std(w_EquityIssuance) 
egen scaled_w_revt = std(w_revt) 
egen scaled_w_cogs = std(w_cogs) 
egen scaled_w_xsga = std(w_xsga) 
egen scaled_w_profitability = std(w_profitability) 
egen scaled_w_agec = std(w_agec) 
egen scaled_w_AssetGrowth = std(w_AssetGrowth) 
egen scaled_w_Sharegrowth = std(w_Sharegrowth) 

egen scaled_exp_ratio = std(exp_ratio) 
egen scaled_assets = std(assets) 
egen scaled_ClassSize = std(mtna_class_sum) 
egen scaled_family_size = std(family_size) 
egen scaled_fund_age = std(fund_age) 
egen scaled_actual_12b1 = std(actual_12b1) 
egen scaled_turn_ratio = std(turn_ratio) 

*** 


save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT, ready.dta"




 





*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\holdings2.dta", clear 

* unique identifier: fundno, fundname, wficn, cusip, ticker, year month 

collapse (sum) shares, by(fundno fundname assets year wficn mgmt_cd inst_fund ticker) 	// from 23.4M to 20.3M  

merge m:1 ticker year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa1.dta" 	// 14.2M out of 20.3M merged 
keep if _merge == 3 
drop _merge 


// save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\holdings2_compa1.dta" ///////// 

merge m:1 wficn year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_multiclass1.dta"	// 13M out of 14M merged 
keep if _merge == 3
drop _merge 


// save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\holdings2_compa1_fundmonthlymulticlass.dta"

* ticker, gvkey, year 

merge m:1 ticker gvkey year using "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa_addtt.dta" 	// 12M out of 13M merged 
keep if _merge == 3 
drop _merge  

save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\FIRST PARTT.dta" 



*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa_addt.dta", clear 

rename tic ticker 
replace ticker = subinstr(ticker, ".", "", .)

rename fyear year 
rename addzip zipcode 
rename incorp state 
rename spcsrc SP_quality 

g ipo_year = year(ipodate) 

keep gvkey year ticker cusip cik zipcode state naics mkvalt SP_quality ipodate ipo_year 

duplicates drop ticker gvkey year, force	// 35K observations deleted 

save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa_addt.dta", replace 



*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_multiclass.dta", clear 

generate year = year(dofc(ym))

drop index caldt ym 

collapse (mean) mtna mnav exp_ratio actual_12b1 turn_ratio mtna_class_sum, by(wficn year) // from 2.4M to 86K 

save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_multiclass1.dta"




*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa1.dta", clear 

* unique identifier: gvkey, tick, cusip, permno, year, month 

// duplicates list cusip ticker ym 

collapse (mean) at bkvlps seq cshi ppegt capx ch che xrd csho ceq txdb lt pstk revt cogs xsga tie, by(gvkey ticker permno year)	// from 301,823 to 356,129  

duplicates drop ticker year, force   

destring gvkey, replace 
xtset gvkey year 
gen lag_assets = L.at
gen asset_growth = at / lag_assets

gen lag_ShareOutstanding = L.csho
gen Share_growth = at / lag_ShareOutstanding

save "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\compa1.dta", replace 








*** OTHERS 
*** 
use "C:\Users\lkn3\Desktop\BUSI 525\Replication for Cheaper is not better\Data output (STATA)\fund_monthly_ret.dta", clear 

collapse (mean) mret gret exp_ratio actual_12b1 turn_ratio mktrf smb hml rmw cma rf umd, by(wficn year)	// from 923K to 86K 

* mktrf = market factor (Rm - Rf) = value-weighted returns on all NYSE, AMEX, NASDAQ stocks MINUS one-month T-bill rate 

*** GROSS ALPHA 
g gAlpha_CAPM = gret - mktrf  
g gAlpha_FF3 = gret - mktrf - smb - hml 
g gAlpha_FF4 = gret - mktrf - smb - hml - umd 
g gAlpha_FF5 = gret - mktrf - smb - hml - rmw - cma 

*** NET ALPHA 
g nAlpha_CAPM = mret - mktrf  
g nAlpha_FF3 = mret - mktrf - smb - hml 
g nAlpha_FF4 = mret - mktrf - smb - hml - umd 
g nAlpha_FF5 = mret - mktrf - smb - hml - rmw - cma



