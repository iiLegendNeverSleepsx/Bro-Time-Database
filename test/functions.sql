-- All columns.
CREATE VIEW test.columns AS
SELECT nextval('test.tests') AS id, table_schema AS schema, table_name AS table, column_name AS column
FROM information_schema.columns
WHERE table_schema = 'discord';
-- All columns without implicit range limits.
CREATE VIEW test.columns_unlimited AS
SELECT nextval('test.tests') AS id, table_schema AS schema, table_name AS table, column_name AS column
FROM information_schema.columns
WHERE table_schema = 'discord' AND data_type IN ('ARRAY', 'json', 'jsonb', 'xml');

CREATE FUNCTION test.columns() RETURNS setof text AS $$
DECLARE
	column record;
	all cursor FOR SELECT schema, table, column
		FROM test.columns;
	unlimited cursor FOR SELECT schema, table, column
		FROM test.columns_unlimited;
BEGIN   
	OPEN all;
	LOOP
		FETCH all INTO column;
		EXIT WHEN NOT FOUND;

		RETURN NEXT matches(column.column, '^(?:[a-z]+_)+[a-z]+$', 'Column name contains alphabetic words separated by underscores.');
	END LOOP;
	CLOSE all;
	OPEN unlimited;
	LOOP
		FETCH unlimited INTO column;
		EXIT WHEN NOT FOUND;

		RETURN NEXT col_has_check(column.schema, column.table, column.column, 'Columns that are not implicitly limited on range must be explicitly limited.');
	END LOOP;
	CLOSE unlimited;
END;
$$ LANGUAGE plpgsql;
