/*FIRST IMPORT DATA FROM THE EXCEL DATASET*/

data Gina1;
  set Gina;
  keep ID N1--N8 ADL CognitiveImpairment MMSE Depressed;
run;

data Gina1;
  set Gina1;
  MeanActivity=(N1+N2+N3+N4+N5+N6+N7+N8)/8;
  if Depressed=. then delete;
run;

/*(GAMMA model ~ NEGATIVE BINOMIAL MODEL) ^= PARAMETER ESTIMATES IN R*/
proc genmod data=Gina1;
  model MeanActivity=CognitiveImpairment|Depressed ADL / dist=gamma link=log;
  output out=out_g predicted=predicted;
run;

proc genmod data=Gina1;
  model MeanActivity=CognitiveImpairment|Depressed ADL / dist=nb link=log;
  output out=out_nb predicted=predicted;
run;

/*3-D grid spline (gamma)*/
goptions reset=all;
proc g3grid data=out_g out=Gsmooth;
  grid CognitiveImpairment*ADL=Predicted / spline smooth=0.1;
run;
quit;

goptions reset=all;
proc g3d data=Gsmooth;
  plot CognitiveImpairment*ADL=Predicted / tilt=85 rotate=-120 zmin=0 zmax=4000;
  label CognitiveImpairment="Cognitive Impairment";
  label ADL="ADL score";
  label Predicted="Predicted";
  title h=2 "Bivariate spline-smoothed plot of predicted mean nocturnal activity* (seconds)";
  footnote h=1.5 "* Adjusted for depression";
run;
quit;
title;
