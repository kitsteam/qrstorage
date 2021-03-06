#!/bin/sh

# Only continue if database is ready
while ! pg_isready -q -h $DATABASE_HOST -p $DATABASE_PORT -U $DATABASE_USER
do
  echo "Waiting for database (host: $DATABASE_HOST, port: $DATABASE_PORT, database_user: $DATABASE_USER"
  sleep 2
done

 ./bin/qrstorage eval "Qrstorage.Release.migrate"
 
exec ./bin/qrstorage start
