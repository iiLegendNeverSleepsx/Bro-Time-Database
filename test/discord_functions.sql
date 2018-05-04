CREATE FUNCTION test.AddBot() RETURNS setof text AS $$
BEGIN
	-- Throws if arguments are null.
	RETURN NEXT throws_ok('SELECT discord.AddBot(null) FOR UPDATE;', '22004', 'p_Server_Id must be provided.', 'discord.AddBot should not accept null arguments.');
	-- Creates a Servers record.
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called correctly.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT CAST(0 AS bigint) AS Server_Id;',  'discord.AddBot must have added a Servers record.');
	-- Does not create another record if called again.
	RETURN NEXT col_is_pk('discord', 'servers', 'server_id', 'The Server_Id must uniquely identify the record.');
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called again.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT CAST(0 AS bigint) AS Server_Id;',  'discord.AddBot must keep existing Servers records.');
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION test.Settings() RETURNS setof text AS $$
BEGIN
	-- Setting
	-- Check for null arguments
	RETURN NEXT throws_ok(''SELECT discord.SetSettings(null, '{}') FOR UPDATE;'', '22004', 'p_Namespace must be provided.', 'discord.SetSettings should not accept null arguments.');
	RETURN NEXT throws_ok(''SELECT discord.SetSettings('test1', null) FOR UPDATE;'', '22004', 'p_Value must be provided.', 'discord.SetSettings should not accept null arguments.');
	-- Must create Settings
	RETURN NEXT lives_ok(''SELECT discord.SetSettings('test2', '{}', 0) FOR UPDATE;'', 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok(''SELECT discord.SetSettings('test3', '{}') FOR UPDATE;'', 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq(''SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'test2';'', ''SELECT 'test4' AS Namespace, '{}' AS Value, 0 AS Server_Id;'',  'discord.SetSettings must have added a Settings record (with Server_Id).');
	RETURN NEXT results_eq(''SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'test3';'', ''SELECT 'test3' AS Namespace, '{}' AS Value;'',  'discord.SetSettings must have added a Settings record (without Server_Id).');
	-- Must create User_Settings
	RETURN NEXT lives_ok(''SELECT discord.SetSettings('test4', '{}', 0, 0) FOR UPDATE;'', 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok(''SELECT discord.SetSettings('test5', '{}', null, 0) FOR UPDATE;'', 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq(''SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'test4';'', ''SELECT 'test4' AS Namespace, '{}' AS Value, 0 AS User_Id;'',  'discord.SetSettings must have added a User_Settings record.');
	RETURN NEXT results_eq(''SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'test5';'', ''SELECT 'test5' AS Namespace, '{}' AS Value, 0 AS User_Id;'',  'discord.SetSettings must have added a User_Settings record.');
	-- Must create empty Settings for User_Settings
	RETURN NEXT results_eq(''SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'test4';'', ''SELECT 'test4' AS Namespace, 'null' AS Value, 0 AS Server_Id'', 'discord.SetSettings must create a Settings record for a User_Settings record (with Server_Id).');
	RETURN NEXT results_eq(''SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'test5';'', ''SELECT 'test5' AS Namespace, 'null' AS Value'', 'discord.SetSettings must create a Settings record for a User_Settings record (without Server_Id).');
	-- Must replace existing Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('test2', '{"key": true}', 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace Settings.');
	RETURN NEXT results_eq(''SELECT Value FROM discord.Settings WHERE Namespace = 'test2';'', $sql$SELECT '{"key": true}' AS Value;$sql$,  'discord.SetSettings must replace existing Settings.');
	-- Must replace existing User_Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('test4', '{"key": true}', 0, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace User_Settings.');
	RETURN NEXT results_eq(''SELECT Value FROM discord.User_Settings WHERE Namespace = 'test4';'', $sql$SELECT '{"key": true}' AS Value;$sql$,  'discord.SetSettings must replace existing User_Settings.');
	-- Must not replace Settings for User_Settings
	RETURN NEXT results_eq(''SELECT Value FROM discord.Settings WHERE Namespace = 'test4';'', ''SELECT 'null' AS Value;'', 'discord.SetSettings must not replace a Settings record when replacing a User_Settings record.');
END;
$$ LANGUAGE plpgsql;
