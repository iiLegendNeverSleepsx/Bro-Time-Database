CREATE SCHEMA test;
CREATE TABLE test.tests (
	id serial,
	total integer
);
INSERT INTO test.tests(total)
	VALUES(0);
