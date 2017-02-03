LIBNAME mit 'C:\Documents and Settings\Soutrik Banerjee\Bureau\Nieuw\Project\DB';

DATA ca_cervix_antwerp;
  SET mit.ca_cervix_antwerp;
RUN;

PROC SORT DATA=ca_cervix_antwerp;
  BY age5g nis; /* achtung !!! */
RUN;

DATA ca_cervix (KEEP = age5g totalcas totalpop); /* goed */
  SET ca_cervix_antwerp;
  BY age5g; /* achtung !!! */
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

DATA ca_cervix_m1;
  MERGE ca_cervix_antwerp ca_cervix;
  BY age5g; /* achtung !!! */
RUN;

DATA ca_cervix_m1;
  SET ca_cervix_m1;
  communerate = totalrate*pop;
RUN;

PROC SORT DATA=ca_cervix_m1;
  BY nis age5g; /* achtung !!! */
RUN;

DATA ca_cervix2 (KEEP = nis EXPECTED); /* goed */
  SET ca_cervix_m1;
  BY nis; /* achtung !!! */
  IF FIRST.nis THEN EXPECTED = 0;
     EXPECTED + communerate;
  IF LAST.nis THEN OUTPUT;
RUN;

DATA ca_cervix_m2;
  MERGE ca_cervix_m1 /* trick dataset for merging */ ca_cervix2;
  BY nis; /* achtung !!! */
RUN;

DATA ca_cervix_nomiss;
  SET ca_cervix_m2;
  IF NOT MISSING(long);
RUN;

PROC SORT DATA=ca_cervix_nomiss;
  BY nis age5g; /* check */
RUN;

DATA ca_cervix3 (KEEP = nis EXPECTED);
  SET ca_cervix_nomiss;
  BY nis;
  IF FIRST.nis;
RUN;
/* only 70 gemeenten */

DATA ca_cervix4 (KEEP = nis OBSERVED); /* goed */
  SET ca_cervix_nomiss;
  BY nis; /* achtung !!! */
  IF FIRST.nis THEN OBSERVED = 0;
     OBSERVED + cases;
  IF LAST.nis THEN OUTPUT;
RUN;
/* only 70 gemeenten */

PROC SORT DATA=ca_cervix3;
  BY nis;
RUN;

PROC SORT DATA=ca_cervix4;
  BY nis;
RUN;

DATA ca_cervix_final;
  MERGE ca_cervix4 ca_cervix3;
  BY nis;
RUN;

DATA mit.ca_cervix_rates;
  SET ca_cervix_final;
RUN;
/* age-stratified observed & expected ca-cervix rates in 70 gemeenten */
