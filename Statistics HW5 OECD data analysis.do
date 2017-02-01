/* Homework 5 - OECD data analysis */

// Set working directory
cd "C:\Users\USER\Downloads\DSTI\Machine Learning"
pwd

// Import data
insheet using "oecd.txt", tab clear case

// Rename variables
rename birth_rate birthRate
rename unemployement_rate unemploy
rename percentage_of_worker_primary_sec prWorkPerc
rename percentage_of_worker_secondary_s secWorkPerc
rename price_increase priceIncr
rename infant_mortality infantMort
rename consumption_of_animal_protein animalProteinDiet
rename energy_consumption energyConsum

// Group by countries
sort country
collapse (mean) birthRate (mean) unemploy (mean) prWorkPerc ///
  (mean) secWorkPerc (mean) GDP (mean) asset (mean) priceIncr ///
  (mean) income (mean) infantMort (mean) animalProteinDiet ///
  (mean) energyConsum, by(country)

// summary table of economic indicators
tabstat birthRate unemploy prWorkPerc secWorkPerc GDP asset ///
priceIncr income infantMort animalProteinDiet energyConsum, ///
statistics(mean sd semean median iqr min max cv) missing ///
varwidth(17) columns(statistics) longstub format(%9.2fc)

// Boxplot
graph box birthRate unemploy prWorkPerc secWorkPerc asset ///
  priceIncr income infantMort animalProteinDiet energyConsum, ///
  marker(1, mcolor(navy) msize(tiny)) ytitle(S.E. indicators) ///
  title(Boxplot for socio-economic indicators) scheme(s1color)
graph box GDP, marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(GDP) scheme(s1color) ///
  title(Boxplot for GDP)



// Reimport data
insheet using "oecd.txt", tab clear case

// Re-rename variables
rename birth_rate birthRate
rename unemployement_rate unemploy
rename percentage_of_worker_primary_sec prWorkPerc
rename percentage_of_worker_secondary_s secWorkPerc
rename price_increase priceIncr
rename infant_mortality infantMort
rename consumption_of_animal_protein animalProteinDiet
rename energy_consumption energyConsum

// Create year variable
by country, sort: generate time = _n
generate year = 1975
replace year = 1977 if time == 2
replace year = 1979 if time == 3
replace year = 1981 if time == 4
drop time

// Two-way plots
graph twoway (scatter birthRate year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline birthRate year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Birth Rate in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Birth Rate") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter unemploy year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline unemploy year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Unemployment in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Unemployment") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter prWorkPerc year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline prWorkPerc year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Primary sector worker % in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Primary sector worker %") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter secWorkPerc year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline secWorkPerc year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Secondary sector worker % in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Secondary sector worker %") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter GDP year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline GDP year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("GDP in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("GDP") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter asset year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline asset year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Asset in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Asset") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter priceIncr year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline priceIncr year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Price Increase in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Price Increase") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter income year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline income year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Income in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Income") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter infantMort year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline infantMort year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Infant Mortality in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Infant Mortality") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter animalProteinDiet year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline animalProteinDiet year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Animal protein diet in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Animal protein diet") xtitle("Year") xlabel(1975(2)1981) legend(off)
graph twoway (scatter energyConsum year, sort mcolor(orange) msize(small) msymbol(triangle) jitter(0.05)) ///
  (mspline energyConsum year, lcolor(dkgreen) lwidth(thick) lpattern(dash_dot)) ///
  , title("Energy consumption in OECD countries") subtitle("Using smoothed spline") ///
  scheme(sj) ytitle("Energy consumption") xtitle("Year") xlabel(1975(2)1981) legend(off)

// Boxplots
graph box birthRate, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Birth Rate) title(Boxplot for Birth Rate) scheme(sj)
graph box unemploy, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Unemployment) title(Boxplot for Unemployment) scheme(sj)
graph box prWorkPerc, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Primary sector worker %) title(Boxplot for Primary sector worker %) scheme(sj)
graph box secWorkPerc, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Secondary sector worker %) title(Boxplot for Secondary sector worker %) scheme(sj)
graph box GDP, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(GDP) title(Boxplot for GDP) scheme(sj)
graph box asset, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Asset) title(Boxplot for Asset) scheme(sj)
graph box priceIncr, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Price Increase) title(Boxplot for Price Increase) scheme(sj)
graph box income, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Income) title(Boxplot for Income) scheme(sj)
graph box infantMort, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Infant Mortality) title(Boxplot for Infant Mortality) scheme(sj)
graph box animalProteinDiet, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Animal protein diet) title(Boxplot for Animal protein diet) scheme(sj)
graph box energyConsum, over(country) marker(1, mcolor(navy) msize(tiny)) ///
  ytitle(Energy consumption) title(Boxplot for Energy consumption) scheme(sj)
