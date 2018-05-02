#!/bin/bash
set -e

echo "Creating database."
psql -v db_name=$db_name -f create_db.sql -b -a &>install.log

echo "Enabling extensions in database."
psql -f extensions.sql -b -a &>>install.log

echo "Creating schema."
psql -f install.sql -b -a &>> install.log
