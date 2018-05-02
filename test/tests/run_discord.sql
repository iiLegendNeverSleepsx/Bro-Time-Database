\i setup.sql
DECLARE
	total integer;
BEGIN
	total := (SELECT SUM(total)
		FROM test.tests
		WHERE schema = 'shared' OR schema = 'discord');
	plan(total);
END;

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
