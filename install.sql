\set ECHO all
\qecho 'Installing database schema...'

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

\qecho 'Done.'
