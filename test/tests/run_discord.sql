\i setup.sql
SELECT no_plan();

-- Standard Tests
SELECT * FROM test.tables();
SELECT * FROM test.columns();
SELECT * FROM test.AddBot();
SELECT * FROM test.Settings();
SELECT * FROM test.Wallet();

SELECT * FROM finish();

ROLLBACK;
