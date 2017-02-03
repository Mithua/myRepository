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


/*random intercept & slope poisson model*/
proc glimmix data=GinaL empirical;
  nloptions maxiter=250 technique=newrap;
  class id;
  model activity=night cognitiveimpairment|depressed adl / s ddfm=satterth d=p;
  random intercept night / subject=id type=un;
  output out=glimmixout_p pred(  blup ilink)=PredVal
                          pred(noblup ilink)=PredVal_PA /*PA:population-averaged*/
                          residual=residual;
run;
/*generalised chi-square / DF = 593.65*/


/*plotting hierarchical poisson model by CognitiveImpairment*/
goptions reset=all;
proc gplot data=glimmixout_p;
  plot predval*night=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical poisson model by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=glimmixout_p;
  plot predval*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
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

/*plotting hierarchical poisson model by disability*/
data glimmixout_p;
  set glimmixout_p;
  ADL_bin=0;
  if ADL le 3 then ADL_bin=1;
run;

goptions reset=all;
proc gplot data=glimmixout_p;
  plot predval*night=ADL_bin / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not disabled" "Disabled" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "GLMM: predicted nocturnal activity (seconds) by group, 95% CI";
run;
quit;
