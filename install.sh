#!/bin/bash
set -e

echo "Creating database."
psql -v db_user=$db_user -v db_pass=$db_pass -v db_name=$db_name -h $db_host -U postgres -f create_db.sql &>install.log

echo "Enabling extensions in database."
psql -h $db_host -d $db_name -U postgres -f extensions.sql &>>install.log

echo "Creating schema."
psql -h $db_host -d $db_name -U $db_user -f install.sql &>> install.log
