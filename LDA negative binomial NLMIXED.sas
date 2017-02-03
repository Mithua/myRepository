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


/*fitting glmm negative binomial model*/
/*random slope model1 - writing the loglikelihood*/
proc nlmixed data=GinaL qpoints=25 maxiter=100;
  parms intercept=6.7 N=-0.01 C=1.2 A=-0.25 D=0.95 I=-1.1 k=1 d11=0.9 d12=-0.035 d22=0.008;
  eta=intercept+b1+N*night+C*cognitiveimpairment+D*depressed+I*cognitiveimpairment*depressed+A*adl+b2*night;
  lambda=exp(eta);
  p=lambda/(lambda+(1/k)); /*here k=dispersion parameter*/
  ll=lgamma(activity+(1/k))-lgamma(activity+1)-lgamma(1/k)+activity*log(p)+(1/k)*log(1-p);
  *ll=activity*log(k*lambda)-(activity+(1/k))*log(1+(k*lambda))+lgamma(activity+(1/k))
      -lgamma(1/k)-lgamma(activity+1); /*alternate general likelihood equation*/
  model activity~general(ll);
  random b1 b2~normal([0,0],[d11,d12,d22]) subject=id out=eb;
  predict lambda out=nlmixedout_nb;
run;

/*OPTIMISATION COULD NOT BE COMPLETED EVEN AFTER RUNNING FOR 20-30 MINUTES USING 25 QUADRATURE POINTS*/

/*random slope model1 - direct way*/
proc nlmixed data=GinaL qpoints=25 maxiter=100;
  parms intercept=6.7 N=-0.01 C=1.2 A=-0.25 D=0.95 I=-1.1 k=1 d11=0.9 d12=-0.035 d22=0.008;
  eta=intercept+b1+N*night+C*cognitiveimpairment+D*depressed+I*cognitiveimpairment*depressed+A*adl+b2*night;
  mu=exp(eta);
  p=1/(1+mu*k);
  model activity~negbin(1/k,p); /*here (1/k)=dispersion parameter=Agresti's notation*/
  random b1 b2~normal([0,0],[d11,d12,d22]) subject=id out=eb;
  predict mu out=nlmixedout_nb;
run;
/*
d12, d22 both not significant;
programme ran for 1:45 hours*/
/*-2LL=4160.3; AICc=4181.2*/

/*random slope model2 - direct way*/
proc nlmixed data=GinaL qpoints=25 maxiter=100;
  parms intercept=6.7 N=-0.01 C=1.2 A=-0.25 D=0.95 I=-1.1 k=1 d11=0.9 d22=0.008;
  eta=intercept+b1+N*night+C*cognitiveimpairment+D*depressed+I*cognitiveimpairment*depressed+A*adl+b2*night;
  mu=exp(eta);
  p=1/(1+mu*k);
  model activity~negbin(1/k,p); /*here (1/k)=dispersion parameter=Agresti's notation*/
  random b1 b2~normal([0,0],[d11,0,d22]) subject=id out=eb;
  predict mu out=nlmixedout_nb;
run;
/*
removing d12;
does not fully converge*/

/*random intercept model - direct way*/
proc nlmixed data=GinaL qpoints=25 maxiter=100;
  parms intercept=6.7 N=-0.01 C=1.2 A=-0.25 D=0.95 I=-1.1 k=1.5 d11=0.9;
  eta=intercept+b1+N*night+C*cognitiveimpairment+D*depressed+I*cognitiveimpairment*depressed+A*adl;
  mu=exp(eta);
  p=1/(1+mu*k);
  model activity~negbin(1/k,p); /*here (1/k)=dispersion parameter=Agresti's notation*/
  random b1~normal(0,d11) subject=id out=eb;
  predict mu out=nlmixedout_nb;
run;
/*
removing d22*/
/*-2LL=4136.6; AICc=4153.2*/


/*plotting hierarchical negative binomial model by CognitiveImpairment*/
goptions reset=all;
proc gplot data=nlmixedout_nb;
  plot pred*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical negative binomial model by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=nlmixedout_nb;
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

/*plotting hierarchical negative binomial model by disability*/
data nlmixedout_nb;
  set nlmixedout_nb;
  ADL_bin=0;
  if ADL le 3 then ADL_bin=1;
run;

goptions reset=all;
proc gplot data=nlmixedout_nb;
  plot pred*night=ADL_bin / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not disabled" "Disabled" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*saving residuals*/
data residuall;
  set nlmixedout_nb;
  residual=pred-activity;
run;
quit;

/*transforming vertical data to horizontal*/
proc sort data=residuall;
  by id;
run;

proc transpose data=residuall out=residualw prefix=resid;
    by id;
    id night;
    var residual;
run;

data residualw;
  set residualw;
  drop _name_;
run;
