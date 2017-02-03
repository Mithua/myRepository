/*FIRST IMPORT DATA FROM THE EXCEL DATASET*/

data Gina1;
  set Gina;
  MeanActivity=(N1+N2+N3+N4+N5+N6+N7+N8)/8;
  if Depressed=. then delete;
run;

proc sort data=Gina1;
  by MeanActivity;
run;

data Gina1;
  set Gina1;
  if MeanActivity > 1700 then Pacer=1; /*cf. Satlin et al.*/
  else Pacer=0;
run;

proc logistic data=Gina1 descending;
  model Pacer=cognitiveimpairment|depressed ADL hypnotics antidepressants neuroleptics
              weight prosthesis continence / selection=b;
run;

proc logistic data=Gina1 descending;
  model Pacer=ADL;
  output out=logout1 prob=predicted difchisq=difchi;
run;

proc sort data=logout1; by ADL; run;

goptions reset=all;
proc gplot data=logout1;
  plot predicted*ADL / haxis=axis1 vaxis=axis2;
  symbol1 i=join c=black l=1 w=3 mode=include;
  axis1 label=(h=1 'ADL') value=(h=1);
  axis2 label=(h=1 A=90 'Probability') value=(h=1);
  title h=2 "Predicted probability of being a 'pacer' by ADL";
run;
quit;
title;

goptions reset=all;
symbol1 pointlabel=("#id" h=1) value=none;
proc gplot data=logout1;
  plot difchi*predicted;
run;
quit;
/*outliers=obs 8, 9, 29*/





proc logistic data=Gina1 descending;
  model Pacer=ADL;
  output out=logout1 pred=fitted upper=HiCI lower=LoCI;
run;

proc freq data=logout1;
  table ADL*Pacer;
run;

proc sort data=logout1;
  by Pacer ADL;
run;

data logout1;
  set logout1;
  Patid=_n_;
run;

data test;
  input Patid prob_observed;
datalines;
1 0
2 40
3 40
4 50
5 50
6 40
7 0
8 0
9 0
10 0
11 50
12 14.29
13 14.29
14 14.29
15 14.19
16 14.29
17 14.29
18 0
19 0
20 0
21 0
22 0
23 100
24 100
25 100
26 100
27 40
28 40
29 100
30 50
31 50
32 50
33 14.29
;
run;

data logout1;
  set logout1;
  merge logout1 test;
  by Patid;
run;

proc sort data=logout1;
  by ADL;
run;

data logout1;
  set logout1;
  Predicted=fitted*100;
  upper=HiCI*100;
  lower=LoCI*100;
run;

goptions reset=all norotate hpos=0 vpos=0 htext=1 ftext=swiss ctext= target= gaccess= gsfmode=;
goptions device=win ctext=black graphrc interpol=join;
symbol1 c=black i=non v=dot;
symbol2 c=purple i=join value=none;
symbol3 c=green i=join value=none line=2;
symbol4 c=green i=join value=none line=2;
axis1 color=black width=1 label=('ADL');
axis2 color=black width=1 label=(angle=90 'Observed and Fitted (95% CI)');
legend1 frame position=(bottom center outside) value=('observed' 'fitted' 'lower' 'upper');
proc gplot data=logout1;
  plot (prob_observed predicted lower upper)*ADL / overlay haxis=axis1 vaxis=axis2 frame legend=legend1;
title c=black h=2 "Probability of being a 'pacer' (95% CIs) by ADL";
run;
quit;
