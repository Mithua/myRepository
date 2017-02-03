LIBNAME temp 'C:\Documents and Settings\sbanerjee\My Documents\Mit\Master Biostatistics\Hausaufgaben\Disease Mapping\Nieuw\Project\DB';

PROC SQL;
  CREATE TABLE total AS
  SELECT SUM(observed) AS totobs, SUM(expected) AS totexp
  FROM temp.ca_cervix_rates;
QUIT;

DATA total;
  SET total;
  sir = totobs/totexp;
  ucl = sir*exp(1.96/sqrt(totobs));
  lcl = sir/exp(1.96/sqrt(totobs));
RUN;
