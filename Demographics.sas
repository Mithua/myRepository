/*FIRST IMPORT DATA FROM THE EXCEL DATASET*/

data Gina1;
  set Gina;
  if Depressed=. then delete;
  MeanActivity=(N1+N2+N3+N4+N5+N6+N7+N8)/8;
run;

%macro demographics_np (var1=);
  proc npar1way data=Gina1;
    class cognitiveimpairment;
  var &var1;
  run;
%mend;

%macro demographics_mean (var1);
  proc sort data=Gina1;
    by cognitiveimpairment &var1;
  run;
  proc means data=Gina1;
    var &var1;
	by cognitiveimpairment;
  run;
  quit;
%mend;

%macro demographics_cat (var1);
  proc freq data=Gina1;
    table cognitiveimpairment*&var1 / fisher;
  run;
%mend;

%demographics_np (var1=MMSE);
%demographics_mean (var1=MMSE);
%demographics_np (var1=ADL);
%demographics_mean (var1=ADL);
%demographics_np (var1=weight);
%demographics_mean (var1=weight);
%demographics_np (var1=MeanActivity);
%demographics_mean (var1=MeanActivity);

%demographics_cat (var1=disabled);
%demographics_cat (var1=depressed);
%demographics_cat (var1=prosthesis);
%demographics_cat (var1=hypnotics);
%demographics_cat (var1=antidepressants);
%demographics_cat (var1=neuroleptics);
%demographics_cat (var1=continence);
%demographics_cat (var1=Gina);
