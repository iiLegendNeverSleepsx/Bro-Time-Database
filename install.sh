#!/bin/bash
set -e

if [ ! -f install.cfg ] ; then
 echo 'Error! File install.cfg does not exist. Please create it:
	$ cp install.cfg.example install.cfg
	$ vi install.cfg'

 exit 1
fi;

# Load settings:
. install.cfg
read -p "The database schema owner is $db_user, password:" db_pass

echo "Creating database."
psql -v db_user=$db_user -v db_pass="'$db_pass'" -v db_name=$db_name -h $db_host -U postgres -f create_db.sql &>install.log

echo "Enabling extensions in database."
psql -h $db_host -d $db_name -U postgres -f extensions.sql &>>install.log

echo "Creating schema."
psql -h $db_host -d $db_name -U $db_user -f install.sql &>> install.log

