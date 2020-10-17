  -- Se realiza la carga del archivo de una ruta Local  
  codSepomex  = LOAD '/inputData/CPdescarga.txt' USING PigStorage('|');
  
  -- Se realiza la proyeccion de solo 2 campos (Cod. Postal, Nombre Colonia)
  codPostal = FOREACH codSepomex GENERATE $0,$1;
  
  -- Se realiza el Filtrado por la primera Columna (Cod. Postal)
  codPostalFilter = FILTER codPostal BY $0 == 76902;
  
  -- Se realiza la agrupación por la primera columna (Cod. Postal)
  codPostalGroup = GROUP codPostal BY $0;
  
  -- Se realiza el conteo por la agrupación de Cod. Postal
  codPostalCount  = FOREACH  codPostalGroup  GENERATE group , COUNT(codPostal);  
  
  -- Se realiza el ordenamiento por la segunda columna (Nombre Colonia)
  codPostalOrd = ORDER codPostalCount  BY  $1  DESC; 
  
  -- Se realiza la selección de 50 registros
  codPostalTop = LIMIT codPostalOrd 50;
  dump codPostalTop;