\i setup.sql
SELECT plan(total)
FROM test.tests
WHERE schema = 'discord';

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
