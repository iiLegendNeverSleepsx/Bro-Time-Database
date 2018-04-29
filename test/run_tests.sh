#!/bin/bash
set -e

pg_prove -h $db_host -p $db_port -d $db_name -U postgres tests/run_*.sql
