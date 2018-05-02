\set QUIET 1

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true

BEGIN;
INSERT INTO test.tests(schema, total)
	SELECT schema, total
	FROM test.tests
	WHERE schema = 'shared';
\i data.sql
COMMIT;
