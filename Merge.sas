DATA ca_cervix_antwerp;
  SET ca_cervix_antwerp (KEEP = nis age5g cases pop);
RUN;

PROC SQL;
  SELECT COUNT(DISTINCT nis) AS n
  FROM ca_cervix_antwerp
  WHERE nis LE 13053;
QUIT;
/* city = 70 gemeenten, district = 308 gemeenten */

/* two datasets already sorted by nis */
DATA ca_cervix_antwerp;
  MERGE ca_cervix_antwerp ca_cervix_coordinates;
  BY nis;
RUN;

/* dataset already sorted by mun_code$ */
DATA urbanisatie;
  SET urbanisatie;
  NIS = INPUT(mun_code, BEST12.);
RUN;

DATA urbanisatie;
  SET urbanisatie (DROP = mun_code);
RUN;

PROC SQL;
  CREATE TABLE ca_cervix AS
  SELECT a.*, b.*
  FROM ca_cervix_antwerp AS a LEFT JOIN urbanisatie AS b
  ON a.nis = b.nis;
QUIT;

PROC SORT DATA=ca_cervix;
  BY nis age5g;
RUN;

LIBNAME mit 'C:\Documents and Settings\sbanerjee\My Documents\Mit\Master Biostatistics\Hausaufgaben\Disease Mapping\Nieuw\Project\DB';

DATA mit.ca_cervix_antwerp;
  SET ca_cervix;
RUN;
