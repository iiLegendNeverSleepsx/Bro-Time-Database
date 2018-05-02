\i setup.sql
DO $$
DECLARE
	v_total integer;
BEGIN
	v_total := (SELECT SUM(total)
		FROM test.tests
		WHERE schema = 'shared' OR schema = 'discord');
	plan(v_total);
END;
$$

-- Standard Tests
SELECT * FROM test.columns();

SELECT * FROM finish();
