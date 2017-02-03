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


/*random intercept model*/
/*poisson*/
proc glimmix data=GinaL method=rspl;
  class id;
  nloptions maxiter=1000 technique=newrap;
  model activity=night cognitiveimpairment|depressed adl / s ddfm=satterth d=p link=log;
  random night / subject=id type=rsmooth knotmethod=kdtree(bucket=1000 knotinfo treeinfo);
  output out=rsmoothout_p pred(  blup ilink)=PredVal
                          pred(noblup ilink)=PredVal_PA /*PA:population-averaged*/
						  residual=residual;
run;
/*generalised chi-square / DF = 569.55*/

/*negative binomial*/
proc glimmix data=GinaL method=rspl;
  class id;
  nloptions maxiter=1000 technique=newrap;
  model activity=night cognitiveimpairment|depressed adl / s ddfm=satterth d=nb link=log;
  random night / subject=id type=rsmooth knotmethod=kdtree(bucket=1000 knotinfo treeinfo);
  output out=rsmoothout_nb pred(  blup ilink)=PredVal
                           pred(noblup ilink)=PredVal_PA /*PA:population-averaged*/
						   residual=residual;
run;
/*generalised chi-square / DF = 1.00*/
/*intraclass correlation = 0.008*/


/*plotting hierarchical poisson model by CognitiveImpairment*/
goptions reset=all;
proc gplot data=rsmoothout_p;
  plot predval*night=cognitiveimpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical poisson model by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=rsmoothout_p;
  plot predval*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  symbol3 c=brown v=none i=stdm2jt l=3 w=2 mode=include;
  symbol4 c=blue v=none i=stdm2jt l=4 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not dementia, not depressed" "Not dementia, depressed" "Dementia, not depressed" "Dementia, depressed" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical poisson model by disability*/
data rsmoothout_p;
  set rsmoothout_p;
  ADL_bin=0;
  if ADL le 3 then ADL_bin=1;
run;

goptions reset=all;
proc gplot data=rsmoothout_p;
  plot predval*night=ADL_bin / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not disabled" "Disabled" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;

/*plotting hierarchical negative binomial model by CognitiveImpairment*/
goptions reset=all;
proc gplot data=rsmoothout_nb;
  plot predval*night=cognitiveimpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical negative binomial model by CognitiveImpairment x depressed interaction*/
goptions reset=all;
proc gplot data=rsmoothout_nb;
  plot predval*night=interaction / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  symbol3 c=brown v=none i=stdm2jt l=3 w=2 mode=include;
  symbol4 c=blue v=none i=stdm2jt l=4 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not dementia, not depressed" "Not dementia, depressed" "Dementia, not depressed" "Dementia, depressed" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;
quit;

/*plotting hierarchical negative binomial model by disability*/
data rsmoothout_nb;
  set rsmoothout_nb;
  ADL_bin=0;
  if ADL le 3 then ADL_bin=1;
run;

goptions reset=all;
proc gplot data=rsmoothout_nb;
  plot predval*night=ADL_bin / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 c=black v=none i=stdm2jt l=1 w=2 mode=include;
  symbol2 c=red v=none i=stdm2jt l=2 w=2 mode=include;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 "Predicted") value=(h=1) order=(0 to 3000 by 1000) minor=none;
  legend1 value=("Not disabled" "Disabled" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title h=2 "Random spline: pred. noct. activity (seconds) by group, 95% CI";
run;


/*Boxplot by CognitiveImpairment*/
proc sort data=rsmoothout_nb;
  by CognitiveImpairment;
run;

data rsmoothout_nb;
  set rsmoothout_nb;
  timegroup=night+(CognitiveImpairment/10);
run;

goptions reset=all;
proc gplot data=rsmoothout_nb;
  plot residual*timegroup=CognitiveImpairment / haxis=axis1 vaxis=axis2 legend=legend1;
  symbol1 i=box v=plus c=black;
  symbol2 i=box v=star c=red;
  axis1 label=(h=1 'Night') value=(h=1) minor=none;
  axis2 label=(h=1 A=90 'Residual') value=(h=1) minor=none;
  legend1 value=("'Normal' cognitive function" "Cognitively impaired" h=1) label=none frame position=(bottom center outside) offset=(0,0);
  title1 h=2 "Boxplots of residuals (random-intercept) by group";
  title2 h=1 "random splines (proc glimmix)";
run;
quit;

/*transforming vertical data to horizontal*/
proc sort data=rsmoothout_nb;
  by id;
run;

proc transpose data=rsmoothout_nb out=residualw prefix=resid;
    by id;
    id night;
    var residual;
run;

data residualw;
  set residualw;
  drop _name_;
run;





/***examining some basic associations in the cross-sectional data***/
data Gina;
  set Gina;
  interaction=cognitiveimpairment||depressed;
run;

proc freq data=Gina;
  table interaction*disabled / chisq fisher;
run;
/*not significant*/

proc freq data=Gina;
  table cognitiveimpairment*disabled / chisq fisher;
run;
/*not significant*/

proc freq data=Gina;
  table cognitiveimpairment*depressed / chisq fisher;
run;
/*not significant*/

proc freq data=Gina;
  table depressed*disabled / chisq fisher;
run;
/*not significant*/
