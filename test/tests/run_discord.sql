\i setup.sql
PERFORM plan(SELECT CAST(SUM(total) AS integer)
	FROM test.tests
	WHERE schema = 'shared' OR schema = 'discord');

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
