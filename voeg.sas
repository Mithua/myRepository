LIBNAME his 'C:\Documents and Settings\sbanerjee\My Documents\Mit\Master Biostatistics\Hausaufgaben\SM\Dataset';

DATA bmi;
  SET his.bmi_voeg;
RUN;

/*
PROC UNIVARIATE DATA = bmi;
  VAR bmi;
  HISTOGRAM;
  QQPLOT;
RUN;
*/

* categorise outcome, delete missing and less than normal outcome values;
DATA bmi2;
  LENGTH bmicatc $12;
  LENGTH bmicatn 8;
  SET bmi (WHERE =(bmi ^= .));
  IF bmi < 18.5 THEN DELETE;
  ELSE IF 18.5 =< bmi =< 25 THEN DO;
    bmicatn = 1;
	bmicatc = 'Normal';
  END;
  ELSE IF 25 < bmi =< 30 THEN DO;
    bmicatn = 2;
	bmicatc = 'Overweight';
  END;
  ELSE DO;
    bmicatn = 3;
	bmicatc = 'Obese';
  END;
RUN;

* categorise predictor - voeg, delete missing predictor values;
DATA bmi2;
  SET bmi2 (WHERE =(ghqbin ^= . AND sgp ^= . AND voeg ^= . AND regionch ^= ''));
  IF voeg =< 2 THEN voegcatn = 0;
  ELSE voegcatn = 1;
RUN;

/*
PROC SORT DATA = bmi2;
  BY id hh;
RUN;
*/

PROC FREQ DATA = bmi2;
  TABLES bmicatn*sgp;
  TABLES bmicatn*voegcatn;
  TABLES bmicatn*ghqbin;
RUN;





* baseline category logit model: srs;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: SRS (by region)';
  BY regionch;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: srs;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: SRS (overall)';
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: srs;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: SRS (by region)';
  BY regionch;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: srs;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: SRS (overall)';
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: strat;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: STRAT (by region)';
  BY regionch;
  STRATA province;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: strat;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: STRAT (overall)';
  STRATA province;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: strat;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: STRAT (by region)';
  BY regionch;
  STRATA province;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: strat;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: STRAT (overall)';
  STRATA province;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: wt;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: WEIGHTED (by region)';
  BY regionch;
  WEIGHT wfin;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: wt;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: WEIGHTED (overall)';
  WEIGHT wfin;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: wt;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: WEIGHTED (by region)';
  BY regionch;
  WEIGHT wfin;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: wt;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: WEIGHTED (overall)';
  WEIGHT wfin;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: clust;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: CLUST (by region)';
  BY regionch;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: clust;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: CLUST (overall)';
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: clust;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: CLUST (by region)';
  BY regionch;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: clust;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: CLUST (overall)';
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
RUN;

* baseline category logit model: all;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: ALL (by region)';
  BY regionch;
  STRATA province;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
  WEIGHT wfin;
RUN;

* baseline category logit model: all;
PROC SURVEYLOGISTIC DATA = bmi2;
  TITLE 'B-C logit model: ALL (overall)';
  STRATA province;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
  WEIGHT wfin;
RUN;

* baseline category logit model: all;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: ALL (by region)';
  BY regionch;
  STRATA province;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
  WEIGHT wfin;
RUN;

* baseline category logit model: all;
PROC SURVEYLOGISTIC DATA = bmi2 TOTAL = 10000000;
  TITLE 'B-C logit model: ALL (overall)';
  STRATA province;
  CLUSTER hh;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn;
  MODEL bmicatn (REF = '1') = sgp voegcatn ghqbin / LINK = GLOGIT;
  WEIGHT wfin;
RUN;





* baseline category logit model: gee ind;
PROC LOGISTIC DATA = bmi2 DESCENDING;
  TITLE 'B-C logit model: (by region) IND';
  BY regionch;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn = sgp voegcatn ghqbin / LINK = GLOGIT EXPB;
RUN;

* baseline category logit model: gee ind;
PROC LOGISTIC DATA = bmi2 DESCENDING;
  TITLE 'B-C logit model: (overall) IND';
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn = sgp voegcatn ghqbin / LINK = GLOGIT EXPB;
RUN;

* baseline category logit model: gee wt;
PROC LOGISTIC DATA = bmi2 DESCENDING;
  TITLE 'B-C logit model: (by region) WT';
  BY regionch;
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn = sgp voegcatn ghqbin / LINK = GLOGIT EXPB;
  WEIGHT wfin;
RUN;

* baseline category logit model: gee wt;
PROC LOGISTIC DATA = bmi2 DESCENDING;
  TITLE 'B-C logit model: (overall) WT';
  CLASS sgp (PARAM = REF REF = '1')
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn = sgp voegcatn ghqbin / LINK = GLOGIT EXPB;
  WEIGHT wfin;
RUN;





* baseline category logit model: glmm ind;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (by region) IND';
  BY regionch;
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = UN GROUP = bmicatn;
RUN;

* baseline category logit model: glmm ind;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (overall) IND';
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = UN GROUP = bmicatn;
RUN;

* baseline category logit model: glmm wt;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (by region) WT';
  BY regionch;
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = UN GROUP = bmicatn;
  WEIGHT wfin;
RUN;

* baseline category logit model: glmm wt;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (overall) WT';
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = UN GROUP = bmicatn;
  WEIGHT wfin;
RUN;

* baseline category logit model: glmm cs;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (by region) CS';
  BY regionch;
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = CS GROUP = bmicatn;
RUN;

* baseline category logit model: glmm cs;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (overall) CS';
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = CS GROUP = bmicatn;
RUN;

* baseline category logit model: glmm wt cs;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (by region) WT CS';
  BY regionch;
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = CS GROUP = bmicatn;
  WEIGHT wfin;
RUN;

* baseline category logit model: glmm wt cs;
PROC GLIMMIX DATA = bmi2 METHOD = RSPL;
  NLOPTIONS MAXITER = 250 TECHNIQUE = NEWRAP;
  TITLE 'B-C logit model: GLMM (overall) WT CS';
  CLASS sgp
        ghqbin
        voegcatn
        hh;
  MODEL bmicatn (ORDER = FREQ REF = FIRST) = sgp voegcatn ghqbin / S DDFM = KR LINK = GLOGIT DIST = MULTINOMIAL ODDSRATIO;
  RANDOM intercept / SUBJECT = hh TYPE = CS GROUP = bmicatn;
  WEIGHT wfin;
RUN;
