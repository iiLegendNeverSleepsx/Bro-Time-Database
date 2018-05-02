\i setup.sql
SELECT no_plan();

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();

ROLLBACK;
