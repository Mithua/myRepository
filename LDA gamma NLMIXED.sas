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


/*fitting glmm gamma model*/
/*random intercept model*/
proc nlmixed data=GinaL qpoints=25 maxiter=100;
  parms intercept=6.7 N=-0.01 C=1.2 A=-0.25 D=0.95 I=-1.1 alpha=10 beta=25 d11=0.9;
  eta=intercept+b1+N*night+C*cognitiveimpairment+D*depressed+I*cognitiveimpairment*depressed+A*adl;
  mu=exp(eta);
  beta=mu/alpha;
  model activity~gamma(alpha,beta);
  random b1~normal(0,d11) subject=id out=eb;
  predict mu out=nlmixedout_g;
run;
/*none of the model parameters significant, except alpha, beta ???*/


/*plotting hierarchical gamma model by CognitiveImpairment*/
goptions reset=all;
proc gplot data=nlmixedout_g;
  plot pred*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical gamma model by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=nlmixedout_g;
  plot pred*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  symbol3 c=brown v=none i=stdm2jt l=3 w=2 mode=include;
  symbol4 c=blue v=none i=stdm2jt l=4 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not dementia, not depressed" "Not dementia, depressed" "Dementia, not depressed" "Dementia, depressed" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;
/*no need to fit a model for this interaction by recoding the interaction variable as in GEE*/

/*plotting hierarchical gamma model by disability*/
data nlmixedout_g;
  set nlmixedout_g;
  ADL_bin=0;
  if ADL le 3 then ADL_bin=1;
run;

goptions reset=all;
proc gplot data=nlmixedout_g;
  plot pred*night=ADL_bin / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not disabled" "Disabled" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;
