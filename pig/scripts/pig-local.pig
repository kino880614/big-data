  codSepomex  = LOAD '/inputData/CPdescarga.txt' USING PigStorage('|');
  dump codSepomex;
  codPostal = FOREACH codSepomex GENERATE $0,$1;
  dump codPostal;
  codPostalFilter = FILTER codPostal BY $0 == 76902;
  dump codPostalFilter;
  codPostalGroup = GROUP codPostal BY $0;
  dump codPostalGroup;
  codPostalCount  = FOREACH  codPostalGroup  GENERATE group , COUNT(codPostal);  
  dump codPostalCount;
  codPostalOrd = ORDER codPostalCount  BY  $1  DESC; 
  dump codPostalOrd;  
  codPostalTop = LIMIT codPostalOrd 50;
  dump codPostalTop;