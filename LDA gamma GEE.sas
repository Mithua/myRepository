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

/*adding a small constant to outcome*/
data GinaL;
  set GinaL;
  activity=activity+0.1;
run;

/*creating CognitiveImpairment x depressed interaction (from post-hoc analysis)*/
proc sort data=GinaL;
  by CognitiveImpairment depressed;
run;

data GinaL;
  set GinaL;
  interaction=CognitiveImpairment||depressed; /*concatenate the 2 variables*/
run;


/*fitting marginal gamma model*/
/*independence -> mild overdispersion*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=gamma link=log wald type3 noscale;
  repeated subject=ID / modelse corrw type=ind;
  output out=gamma_ind predicted=Pred_ind;
run;
/*Note: model-based SEs are quite different from empirical SEs*/

/*autoregressive -> mild overdispersion*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=gamma link=log wald type3 noscale;
  repeated subject=ID / modelse corrw type=ar;
  output out=gamma_ar predicted=Pred_ar;
run;
/*Note: model-based SEs are quite different from empirical SEs*/

/*exchangeable -> mild overdispersion -> final model selected*/
proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=gamma link=log wald type3 noscale;
  repeated subject=ID / modelse corrw type=exch;
  output out=gamma_exch predicted=Pred_exch;
run;
/*Note: model-based SEs are quite different from empirical SEs*/
/*Note: exchangeable working correlation=0.42 (?? or 0.39) as seen in the correlation graph in R*/

/*unstructured -> mild overdispersion*/
/*proc genmod data=GinaL;
  class ID;
  model activity=night CognitiveImpairment|depressed adl / d=gamma link=log wald type3 noscale;
  repeated subject=ID / modelse corrw type=un;
  output out=gamma_un predicted=Pred_un;
run;
/*Note: too many covariance parameters=no parameter estimates*/

/*further analysis on CognitiveImpairment x depressed interaction*/
proc genmod data=GinaL;
  class ID interaction;
  model activity=night interaction adl / d=gamma link=log wald type3 noscale;
  repeated subject=ID / modelse corrw type=exch;
  estimate 'dementia vs non-dementia (not depressed)' interaction -1 0 1 0 / exp;
  estimate 'dementia vs non-dementia (depressed)' interaction 0 -1 0 1 / exp;
  output out=gamma_exch predicted=Pred_exch; /*equivalent model to the previous*/
run;
/*Note: CognitiveImpairment x depressed interaction estimates are similar to cross-sectional analysis using Treillis graphics in R*/


/*plotting marginal gamma model by CognitiveImpairment - exchangeable*/
goptions reset=all;
proc gplot data=gamma_exch;
  plot pred_exch*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted (under 'exchangeable' covariance)") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GEE: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting marginal gamma model by CognitiveImpairment x depressed interaction - exchangeable*/
goptions reset=all;
proc gplot data=gamma_exch;
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
