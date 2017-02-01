/* --------------------------------------- */
/* HW1new - PCA - Olympic performance data */
/* --------------------------------------- */

// load data
cd C:\Users\mit_7_000\Downloads\
pwd
insheet using "olympic2.txt", tab clear case

// centring variables
foreach var of varlist c100_mt-score {
	quietly summarize `var', meanonly
	generate `var'_cen = `var' - r(mean)
}

// compute SD on centred variables
tabstat c100_mt_cen distance_cen weight_cen /*
*/ height_cen c400_mt_cen c110_mt_cen disc_cen /*
*/ pole_vault_cen javelin_cen c1500_mt_cen score_cen,/*
*/ statistics(sd) noseparator columns(statistics) /*
*/ longstub format(%5.2f)

// standardising variables
foreach var of varlist c100_mt-score {
	quietly summarize `var'
	generate z`var' = ((`var' - r(mean))/r(sd))
}
