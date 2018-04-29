#!/bin/bash
set -e

echo "Dropping database."
psql -v db_user=$db_user -v db_pass="'$db_pass'" -v db_name=$db_name -h $db_host -p $db_port -U postgres -f drop_db.sql
