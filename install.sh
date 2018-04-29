#!/bin/bash
set -e

echo "Creating database."
psql -v db_name=$db_name -h $db_host -p $db_port -U postgres -f create_db.sql &>install.log

echo "Enabling extensions in database."
psql -h $db_host -p $db_port -d $db_name -U postgres -f extensions.sql &>>install.log

echo "Creating schema."
psql -h $db_host -p $db_port -d $db_name -U postgres -f install.sql &>> install.log
