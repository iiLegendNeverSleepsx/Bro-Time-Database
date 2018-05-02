\i setup.sql
SELECT plan(test_totals.total)
FROM (SELECT CAST(SUM(total) AS integer) AS total
	FROM test.tests
	WHERE schema = 'shared' OR schema = 'discord') AS test_totals;

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
