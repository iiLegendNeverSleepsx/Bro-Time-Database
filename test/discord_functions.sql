CREATE FUNCTION test.AddBot() RETURNS setof text AS $$
BEGIN
	RETURN NEXT throws_ok('SELECT discord.AddBot(null) FOR UPDATE;', '22004', 'p_Server_Id must be provided.', 'discord.AddBot should not accept null arguments.');
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called correctly.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0::bigint AS Server_Id;',  'discord.AddBot must have added a Servers record.');
	RETURN NEXT col_is_pk('discord', 'servers', 'server_id', 'The Server_Id must uniquely identify the record.');
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called again.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0::bigint AS Server_Id;',  'discord.AddBot must keep existing Servers records.');
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION test.Settings() RETURNS setof text AS $$
BEGIN
	-- Setting
	RETURN NEXT throws_ok($sql$SELECT discord.SetSettings(null::varchar(32), '{}'::jsonb) FOR UPDATE;$sql$, '22004', 'p_Namespace must be provided.', 'discord.SetSettings should not accept null arguments.');
	RETURN NEXT throws_ok($sql$SELECT discord.SetSettings('test1'::varchar(32), null::jsonb) FOR UPDATE;$sql$, '22004', 'p_Value must be provided.', 'discord.SetSettings should not accept null arguments.');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testB'::varchar(32), '{}'::jsonb, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testC'::varchar(32), '{}'::jsonb) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'testB';$sql$, $sql$SELECT 'testB'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS Server_Id;$sql$,  'discord.SetSettings must have added a Settings record (with Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'testC';$sql$, $sql$SELECT 'testC'::varchar(32) AS Namespace, '{}'::jsonb AS Value;$sql$,  'discord.SetSettings must have added a Settings record (without Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testD', '{}'::jsonb, 0, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testE', '{}'::jsonb, null, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'testD'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS User_Id;$sql$,  'discord.SetSettings must have added a User_Settings record.');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'testE';$sql$, $sql$SELECT 'testE'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS User_Id;$sql$,  'discord.SetSettings must have added a User_Settings record.');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'testD'::varchar(32) AS Namespace, 'null'::jsonb AS Value, 0::bigint AS Server_Id;$sql$, 'discord.SetSettings must create a Settings record for a User_Settings record (with Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'testE';$sql$, $sql$SELECT 'testE'::varchar(32) AS Namespace, 'null'::jsonb AS Value;$sql$, 'discord.SetSettings must create a Settings record for a User_Settings record (without Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testB'::varchar(32), '{"key": true}'::jsonb, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace Settings.');
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.Settings WHERE Namespace = 'testB';$sql$, $sql$SELECT '{"key": true}'::jsonb AS Value;$sql$,  'discord.SetSettings must replace existing Settings.');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testD', '{"key": true}'::jsonb, 0, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace User_Settings.');
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.User_Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT '{"key": true}'::jsonb AS Value;$sql$,  'discord.SetSettings must replace existing User_Settings.');
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'null'::jsonb AS Value;$sql$, 'discord.SetSettings must not replace a Settings record when replacing a User_Settings record.');
	-- Getting
	RETURN NEXT throws_ok($sql$SELECT discord.GetSettings(null);$sql$, '22004', 'p_Namespace must be provided.', 'discord.GetSettings should not accept null arguments.');
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testB', 0);$sql$, $sql$SELECT '{"key": true}'::jsonb;$sql$, 'discord.GetSettings must return settings if called correctly.');
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testD', 0, 0);$sql$, $sql$SELECT '{"key": true}'::jsonb;$sql$, 'discord.GetSettings must return user settings if called correctly.');
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testF');$sql$, $sql$SELECT 'null'::jsonb;$sql$, 'discord.GetSettings must return null jsonb if called with invalid arguments.');
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION test.Wallet() RETURNS setof text AS $$
BEGIN
	-- WalletChange
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(10, null) FOR UPDATE;$sql$, 'discord.WalletChange should not throw for bank user.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(10, 0) FOR UPDATE;$sql$, 'discord.WalletChange should create a wallet.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 10;$sql$, 'discord.WalletGet should return 10 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(-5, 0) FOR UPDATE;$sql$, 'discord.WalletChange should negate 5 bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 5;$sql$, 'discord.WalletGet should return 5 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(5, 0) FOR UPDATE;$sql$, 'discord.WalletChange should add 5 bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 10;$sql$, 'discord.WalletGet should return 10 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(-10, 0) FOR UPDATE;$sql$, 'discord.WalletGet should remove all bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 0;$sql$, 'discord.WalletGet should return 0 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(1000000000, 0) FOR UPDATE;$sql$, 'discord.WalletChange should add maximum bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 1000000000;$sql$, 'discord.WalletGet should return maximum bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(1, 0) FOR UPDATE;$sql$, 'discord.WalletChange should not add another bit.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 1000000000;$sql$, 'discord.WalletGet should return maximum bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(-1000000001, 0) FOR UPDATE;$sql$, 'discord.WalletChange should should subtract more than maximum bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 0;$sql$, 'discord.WalletGet should return 0 bits.');
	RETURN NEXT throws_ok($sql$SELECT discord.WalletChange(null, null);$sql$, '22004', 'p_Amount must be provided.', 'discord.WalletChange must throw if the amount is not provided.');
	-- WalletGet
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(null);$sql$, $sql$SELECT -1;$sql$, 'discord.WalletGet must return -1 for bank user.');
	-- WalletTransfer
	RETURN NEXT throws_ok($sql$SELECT discord.WalletTransfer(10, 1, 0);$sql$, 'P0001', 'No funds available.', 'discord.WalletTransfer must throw if the user does not have bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletChange(10, 0) FOR UPDATE;$sql$, 'discord.WalletChange should add 10 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletTransfer(10, 0, 1) FOR UPDATE;$sql$, 'discord.WalletTransfer should transfer 10 (%20 fee) bits.');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(1);$sql$, $sql$SELECT 8;$sql$, 'discord.WalletGet should return transfered bits (8 bits).');
	RETURN NEXT throws_ok($sql$SELECT discord.WalletTransfer(10, 0, 1);$sql$, 'P0001', 'Not enough funds available.', 'discord.WalletTransfer should throw if missing bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletTransfer(7, 1, 0) FOR UPDATE;$sql$, 'discord.WalletTransfer should transfer bits back (10 bits with %20 fee).');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(0);$sql$, $sql$SELECT 6;$sql$, 'discord.WalletGet should retuurn 7 bits.');
	RETURN NEXT throws_ok($sql$SELECT discord.WalletTransfer(-10, 0, 1);$sql$, 'P0001', 'Can''t transfer back.', 'discord.WalletTransfer should throw if transfering a negative amount.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletTransfer(10, null, 1) FOR UPDATE;$sql$, 'discord.WalletTransfer should transfer from the bank user (10 bits, with %20 fee).');
	RETURN NEXT results_eq($sql$SELECT discord.WalletGet(1);$sql$, $sql$SELECT 14;$sql$, 'discord.WalletGet should return 7 bits.');
	RETURN NEXT lives_ok($sql$SELECT discord.WalletTransfer(14, 1, null) FOR UPDATE;$sql$, 'discord.WalletTransfer should transfer to the bank user (7 bits, with %20 fee).');
	RETURN NEXT throws_ok($sql$SELECT discord.WalletTransfer(null, null, null);$sql$, '22004', 'p_Amount must be provided.', 'discord.WalletTransfer should not accept a null amount.');
END;
$$ LANGUAGE plpgsql;
