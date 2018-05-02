\i setup.sql
SELECT plan(CAST(currval('"test.tests"') AS integer));

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();

ROLLBACK;
