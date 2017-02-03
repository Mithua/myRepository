/*FIRST IMPORT DATA FROM THE EXCEL DATASET*/

/*deleting missing values for depressed variable*/
data Gina;
  set Gina;
  if ID=. then delete;
  if depressed=. then delete;
run;

/*transposing horizontal data to vertical*/
data GinaL (keep=patients ID CognitiveImpairment ADL Depressed night activity);
  set Gina;
  id=_n_;
  array counter {8} N1--N8;
  do i=1 to 8;
    night=i;
    activity=counter{i};
    output GinaL; /*otherwise on 33 obs are created instead of 264 (=33x8)*/
  end;
run;

/*creating CognitiveImpairment x depressed interaction (from post-hoc analysis)*/
proc sort data=GinaL;
  by CognitiveImpairment depressed;
run;

data GinaL;
  set GinaL;
  interaction=CognitiveImpairment||depressed; /*concatenate the 2 variables*/
run;

/*testing association between CognitiveImpairment & depressed*/
proc freq data=Gina;
  table depressed*CognitiveImpairment / fisher chisq;
run;
/*not significant*/


/*individual profiles*/
proc sort data=GinaL;
  by ID;
run;

goptions reset=all;
proc gplot data=GinaL;
  plot activity*night=ID / nolegend;
  symbol1 i=join v=none l=1 r=27;
run;
quit;

/*individual profiles after standardisation to observe possible tracking*/
proc sort data=GinaL;
  by night;
run;

proc stdize data=GinaL out=GinaLZ method=std;
  var activity;
  by night;
run;

goptions reset=all;
proc gplot data=GinaLZ;
  plot activity*night=ID / nolegend;
  symbol1 i=join v=none l=1 r=27;
run;
quit;

/*Boxplot by CognitiveImpairment*/
proc sort data=GinaL;
  by CognitiveImpairment;
run;

data GinaL;
  set GinaL;
  timegroup=night+(CognitiveImpairment/10);
run;

goptions reset=all;
proc gplot data=GinaL;
  plot activity*timegroup=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 i=box v=plus c=black;
  symbol2 i=box v=star c=red;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 'Observed') value=(h=1) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Boxplots of observed nocturnal activity (seconds) by group";
run;
quit;

/*plotting mean (95% CI) observed data by CoginitiveImpairment*/
goptions reset=all;
proc gplot data=GinaL;
  plot activity*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 'Observed') value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Observed nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting mean (95% CI) observed data by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=GinaL;
  plot activity*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  symbol3 c=brown v=none i=stdm2jt l=3 w=2 mode=include;
  symbol4 c=blue v=none i=stdm2jt l=4 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 'Observed') value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not dementia, not depressed" "Not dementia, depressed" "Dementia, not depressed" "Dementia, depressed" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Observed nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*summary measures: boxplot by groups*/
data Gina;
  set Gina;
  MeanActivity=mean(of N1-N8);
run;

proc sort data=Gina;
  by CognitiveImpairment;
run;

goptions reset=all;
proc boxplot data=Gina;
  plot MeanActivity*CognitiveImpairment / boxstyle=schematic;
run;

proc sort data=Gina;
  by Depressed;
run;

goptions reset=all;
proc boxplot data=Gina;
  plot MeanActivity*Depressed / boxstyle=schematic;
run;


/*fitting marginal poisson model*/
/*independence -> overdispersion*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=p wald type3 noscale;
  repeated subject=ID / modelse corrw type=ind;
  output out=Poi_ind predicted=Pred_ind;
run;
/*Note: model-based SEs are quite different from empirical SEs*/

/*autoregressive -> overdispersion*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=p wald type3 noscale;
  repeated subject=ID / modelse corrw type=ar;
  output out=Poi_ar predicted=Pred_ar;
run;
/*Note: model-based SEs are quite different from empirical SEs*/

/*exchangeable -> overdispersion -> final model selected*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=p wald type3 noscale;
  repeated subject=ID / modelse corrw type=exch;
  output out=Poi_exch predicted=Pred_exch;
run;
/*Note: model-based SEs are quite different from empirical SEs*/
/*Note: exchangeable working correlation=0.45 as seen in the correlation graph in R*/
/*Note: night x CognitiveImpairment interaction is not significant (p=0.75)*/

/*unstructured -> overdispersion*/
/*proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=p wald type3 noscale;
  repeated subject=ID / modelse corrw type=un;
  output out=Poi_un predicted=Pred_un;
run;
/*Note: too many covariance parameters=no parameter estimates*/

/*further analysis on CognitiveImpairment x depressed interaction*/
proc genmod data=GinaL;
  class ID interaction;
  model activity=night interaction adl / d=p wald type3 noscale;
  repeated subject=ID / modelse corrw type=exch;
  estimate 'dementia vs non-dementia (not depressed)' interaction -1 0 1 0 / exp;
  estimate 'dementia vs non-dementia (depressed)' interaction 0 -1 0 1 / exp;
  output out=Poi_exch predicted=Pred_exch; /*equivalent model to the previous*/
run;
/*Note: CognitiveImpairment x depressed interaction estimates are similar to cross-sectional analysis using Treillis graphics in R*/


/*plotting marginal poisson model by CognitiveImpairment - exchangeable*/
goptions reset=all;
proc gplot data=Poi_exch;
  plot pred_exch*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted (under 'exchangeable' covariance)") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GEE: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting marginal poisson model by CognitiveImpairment x depressed interaction - exchangeable*/
goptions reset=all;
proc gplot data=Poi_exch;
  plot pred_exch*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  symbol3 c=brown v=none i=stdm2jt l=3 w=2 mode=include;
  symbol4 c=blue v=none i=stdm2jt l=4 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted (under 'exchangeable' covariance)") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not dementia, not depressed" "Not dementia, depressed" "Dementia, not depressed" "Dementia, depressed" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GEE: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;
