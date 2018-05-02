\set ECHO all
\qecho 'Installing database schema...'

BEGIN;
-- Shared
\i test/schema.sql
\i test/functions.sql

-- Schema
\i discord/schema.sql
-- Data types
\i discord/datatypes.sql
-- Tables
\i discord/tables.sql
-- Functions
\i discord/functions.sql
COMMIT;

\qecho 'Done.'
