# big-data

# Debemos generar 2 volumenes para hadoop (datos y logs)

docker volume create hadoop-data
docker volume create hadoop-logs

# Debemos generar 2 volumnes para zeppelin (logs y notebooks)
docker volume create zeppelin-notebook
docker volume create zeppelin-logs

# Iniciar Contenedor

