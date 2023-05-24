#!/bin/bash

SQL="SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN \
  ('mysql','information_schema','performance_schema','sys');"

while :
  do
    read -e -p "Enter the container name: " CONTAINER_NAME
  if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Container name is required."
    sleep 1
  else
    break
  fi
done

while :
  do
    read -e -p "Enter username: " MYSQL_USERNAME
  if [[ -z "$MYSQL_USERNAME" ]]; then
    echo "Username is required."
    sleep 1
  else
    break
  fi
done

while :
  do
    read -e -s -p "Enter the password: " MYSQL_PASSWORD
  if [[ -z "$MYSQL_PASSWORD" ]]; then
    echo "Password is required."
    sleep 1
  else
    echo "Enter the password: "
    break
  fi
done

while :
  do
    read -e -p "Enter the file path of the gzip tar backup: " BACKUP_TAR_FILE_PATH
  if [[ -z "$BACKUP_TAR_FILE_PATH" ]]; then
    echo "Path is required."
    sleep 1
  else
    break
  fi
done

echo "Starting operations at $(date +"%Y-%m-%d_%T"). Restoring all databases from tar file..."
echo "Unzipping all databases from the tar gz file..."
BACKUP_FOLDER_PATH=$(dirname $BACKUP_TAR_FILE_PATH)
cd $BACKUP_FOLDER_PATH
tar -xvzf $BACKUP_TAR_FILE_PATH
dbList=( $(ls $BACKUP_FOLDER_PATH | grep -E '^glosa(_[A-Z0-9]{12})?.sql$') )
for db in "${dbList[@]}"
do
  dbName=$(echo $db | cut -d '.' -f1)
  echo "Restoring $dbName..."
  docker exec -i $CONTAINER_NAME mysql -u"$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $dbName;"
  cat $db | docker exec -i $CONTAINER_NAME mysql -u"$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" $dbName
  echo "Done."
  rm "$BACKUP_FOLDER_PATH/$db.sql"
done
echo "Backup completed!"