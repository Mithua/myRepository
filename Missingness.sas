/*FIRST IMPORT DATA FROM THE EXCEL DATASET*/

data missingness;
  set Gina;
  if Depressed=. then flag=1;
  else flag=0;
  MeanActivity=(N1+N2+N3+N4+N5+N6+N7+N8)/8;
run;

%macro miss (var1=);
  proc sort data=missingness;
    by flag;
  run;
  proc npar1way data=missingness;
    class flag;
    var &var1;
  run;
%mend;

%macro miss_cat (var1=);
  proc freq data=missingness;
    table flag*&var1 / fisher;
  run;
%mend;

/*exposure variable*/
%miss (var1=MMSE); /*NOT SIGNIFICANT*/
%miss_cat (var1=CognitiveImpairment); /*NOT SIGNIFICANT*/

/*covariates*/
%miss (var1=ADL); /*NOT SIGNIFICANT*/
%miss_cat (var1=disabled); /*NOT SIGNIFICANT*/
%miss_cat (var1=prosthesis); /*NOT SIGNIFICANT*/
%miss_cat (var1=hypnotics); /*NOT SIGNIFICANT*/
%miss_cat (var1=antidepressants); /*NOT SIGNIFICANT*/
%miss_cat (var1=neuroleptics); /*NOT SIGNIFICANT*/
%miss_cat (var1=continence); /*NOT SIGNIFICANT*/
%miss_cat (var1=Gina); /*NOT SIGNIFICANT*/

/*outcome variable*/
%miss (var1=MeanActivity); /*NOT SIGNIFICANT*/

/*multivariate dropout model*/
proc logistic data=missingness descending;
  model flag=MMSE ADL prosthesis continence hypnotics antidepressants neuroleptics weight / selection=b;
run;
/*NO SIGNIFICANT VARIABLES*/
