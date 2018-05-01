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
BEGIN   
	
END;
$$ LANGUAGE plpgsql;
