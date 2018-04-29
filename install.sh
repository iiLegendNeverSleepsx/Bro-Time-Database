#!/bin/bash
set -e

echo "Creating database."
psql -v db_name=$db_name -h $db_host -f create_db.sql &>install.log

echo "Enabling extensions in database."
psql -h $db_host -d $db_name -f extensions.sql &>>install.log

echo "Creating schema."
psql -h $db_host -d $db_name -f install.sql &>> install.log
