\i setup.sql
SELECT plan(currval('test.tests'));

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();

ROLLBACK;
