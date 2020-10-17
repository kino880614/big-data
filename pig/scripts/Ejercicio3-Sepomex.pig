  -- PIG con HDFS
  -- Se realiza la carga del archivo de una ruta Local, identificando el mapeo de cada campo
  codSepomex = load 'hdfs://hadoop:9000/inputDir/data/CPdescarga.txt' USING PigStorage('|') as (d_codigo:int,d_asenta:chararray,d_tipo_asenta:chararray,d_mnpio:chararray, d_estado:chararray,	d_ciudad:chararray,	d_CP:chararray,	c_estado:int, c_oficina:int, c_CP:int, c_tipo_asenta:int, c_mnpio:int, id_asenta:int,d_zona:chararray,c_cve_ciudad:int);
 
  -- Se realiza la proyeccion de solo 2 campos (Cod. Postal, Nombre Colonia,Ciudad)
  codPostal = FOREACH codSepomex GENERATE d_codigo,d_asenta,d_ciudad;
  
  -- Se realiza tratamiento de Nulo (Ciudad)
   codPostalNull = FOREACH codPostal GENERATE d_codigo,d_asenta,(d_ciudad is null ? 'N/A' : d_ciudad);
  
  -- Se realiza la concatenación
  codPostalConcat = FOREACH codPostal GENERATE CONCAT((chararray)d_codigo,'-',d_asenta);
  
  -- Se realiza la agrupación por la primera columna (Cod. Postal)
  codPostalGroup = GROUP codPostal BY $0;
  
  -- Se realiza el conteo por la agrupación de Cod. Postal
  codPostalCount  = FOREACH  codPostalGroup  GENERATE group , COUNT(codPostal);  
  
  -- Se realiza el ordenamiento por la segunda columna (Nombre Colonia)
  codPostalOrd = ORDER codPostalCount  BY  $1  DESC; 
  
  -- Se realiza la selección de 10 registros
  codPostalTop = LIMIT codPostalOrd 10;
  
  -- Se almacena el resultado en el HDFS
  STORE codPostalTop INTO ' hdfs://hadoop:9000/outputDir/data/Ejercicio3Pig' USING PigStorage (',');