\i setup.sql
SELECT plan(SUM(total))
FROM test.tests
WHERE schema = 'shared' OR schema = 'discord';

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
