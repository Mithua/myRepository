LIBNAME temp "U:\Data\Temporary\Nieuw\Project\DB";


DATA ca_cervix_antwerp;
  SET temp.ca_cervix_antwerp;
  IF NIS =< 13053;
RUN;

PROC SORT DATA=ca_cervix_antwerp;
  BY age5g nis;
RUN;

DATA ca_cervix (KEEP = age5g totalcas totalpop);
  SET ca_cervix_antwerp;
  BY age5g;
  IF FIRST.age5g THEN totalcas = 0;
  IF FIRST.age5g THEN totalpop = 0;
     totalcas + cases;
	 totalpop + pop;
  IF LAST.age5g THEN OUTPUT;
RUN;

DATA ca_cervix;
  SET ca_cervix;
  totalrate = totalcas/totalpop;
RUN;

GOPTIONS ROTATE=LANDSCAPE;
PROC GPLOT DATA=ca_cervix;
  SYMBOL I=spline C=black W=2 L=2;
  PLOT totalrate*age5g / HAXIS=axis1 VAXIS=axis2;
  AXIS1 LABEL =(H = 1.5 'Age group');
  AXIS2 LABEL =(H = 1.5 A = 90 'Rate');
  TITLE 'Cervix cancer incidence by age group';
RUN;
QUIT;
GOPTIONS RESET=ALL;


PROC SORT DATA=ca_cervix_antwerp;
  BY agglo nis;
RUN;

DATA ca_cervix2 (KEEP = agglo totalcas totalpop);
  SET ca_cervix_antwerp;
  BY agglo;
  IF FIRST.agglo THEN totalcas = 0;
  IF FIRST.agglo THEN totalpop = 0;
     totalcas + cases;
	 totalpop + pop;
  IF LAST.agglo THEN OUTPUT;
RUN;

DATA ca_cervix2;
  SET ca_cervix2;
  totalrate = totalcas/totalpop;
RUN;

GOPTIONS ROTATE=LANDSCAPE;
PROC GPLOT DATA=ca_cervix2;
  SYMBOL I=spline C=black W=2 L=2;
  PLOT totalrate*agglo / HAXIS=axis1 VAXIS=axis2;
  AXIS1 LABEL =(H = 1.5 'Urbanisation');
  AXIS2 LABEL =(H = 1.5 A = 90 'Rate');
  TITLE 'Cervix cancer incidence by urbanisation';
RUN;
QUIT;
GOPTIONS RESET=ALL;
