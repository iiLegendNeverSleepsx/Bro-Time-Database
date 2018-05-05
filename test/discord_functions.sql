CREATE FUNCTION test.AddBot() RETURNS setof text AS $$
BEGIN
	-- Throws if arguments are null.
	RETURN NEXT throws_ok('SELECT discord.AddBot(null) FOR UPDATE;', '22004', 'p_Server_Id must be provided.', 'discord.AddBot should not accept null arguments.');
	-- Creates a Servers record.
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called correctly.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0::bigint AS Server_Id;',  'discord.AddBot must have added a Servers record.');
	-- Does not create another record if called again.
	RETURN NEXT col_is_pk('discord', 'servers', 'server_id', 'The Server_Id must uniquely identify the record.');
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called again.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0::bigint AS Server_Id;',  'discord.AddBot must keep existing Servers records.');
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION test.Settings() RETURNS setof text AS $$
BEGIN
	-- Setting
	-- Check for null arguments
	RETURN NEXT throws_ok($sql$SELECT discord.SetSettings(null::varchar(32), '{}'::jsonb) FOR UPDATE;$sql$, '22004', 'p_Namespace must be provided.', 'discord.SetSettings should not accept null arguments.');
	RETURN NEXT throws_ok($sql$SELECT discord.SetSettings('test1'::varchar(32), null::jsonb) FOR UPDATE;$sql$, '22004', 'p_Value must be provided.', 'discord.SetSettings should not accept null arguments.');
	-- Must create Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testB'::varchar(32), '{}'::jsonb, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testC'::varchar(32), '{}'::jsonb) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'testB';$sql$, $sql$SELECT 'testB'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS Server_Id;$sql$,  'discord.SetSettings must have added a Settings record (with Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'testC';$sql$, $sql$SELECT 'testC'::varchar(32) AS Namespace, '{}'::jsonb AS Value;$sql$,  'discord.SetSettings must have added a Settings record (without Server_Id).');
	-- Must create User_Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testD', '{}'::jsonb, 0, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (with p_Server_Id).');
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testE', '{}'::jsonb, null, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called correctly (without p_Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'testD'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS User_Id;$sql$,  'discord.SetSettings must have added a User_Settings record.');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, User_Id FROM discord.User_Settings WHERE Namespace = 'testE';$sql$, $sql$SELECT 'testE'::varchar(32) AS Namespace, '{}'::jsonb AS Value, 0::bigint AS User_Id;$sql$,  'discord.SetSettings must have added a User_Settings record.');
	-- Must create empty Settings for User_Settings
	RETURN NEXT results_eq($sql$SELECT Namespace, Value, Server_Id FROM discord.Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'testD'::varchar(32) AS Namespace, 'null'::jsonb AS Value, 0::bigint AS Server_Id;$sql$, 'discord.SetSettings must create a Settings record for a User_Settings record (with Server_Id).');
	RETURN NEXT results_eq($sql$SELECT Namespace, Value FROM discord.Settings WHERE Namespace = 'testE';$sql$, $sql$SELECT 'testE'::varchar(32) AS Namespace, 'null'::jsonb AS Value;$sql$, 'discord.SetSettings must create a Settings record for a User_Settings record (without Server_Id).');
	-- Must replace existing Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testB'::varchar(32), '{"key": true}'::jsonb, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace Settings.');
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.Settings WHERE Namespace = 'testB';$sql$, $sql$SELECT '{"key": true}'::jsonb AS Value;$sql$,  'discord.SetSettings must replace existing Settings.');
	-- Must replace existing User_Settings
	RETURN NEXT lives_ok($sql$SELECT discord.SetSettings('testD', '{"key": true}'::jsonb, 0, 0) FOR UPDATE;$sql$, 'discord.SetSettings must not throw if called to replace User_Settings.');
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.User_Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT '{"key": true}'::jsonb AS Value;$sql$,  'discord.SetSettings must replace existing User_Settings.');
	-- Must not replace Settings for User_Settings
	RETURN NEXT results_eq($sql$SELECT Value FROM discord.Settings WHERE Namespace = 'testD';$sql$, $sql$SELECT 'null'::jsonb AS Value;$sql$, 'discord.SetSettings must not replace a Settings record when replacing a User_Settings record.');
	-- Getting
	-- Check for null arguments
	RETURN NEXT throws_ok($sql$SELECT discord.GetSettings(null);$sql$, '22004', 'p_Namespace must be provided.', 'discord.GetSettings should not accept null arguments.');
	-- Settings must be returned if called correctly.
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testB', 0);$sql$, $sql$SELECT '{"key": true}'::jsonb;$sql$, 'discord.GetSettings must return settings if called correctly.');
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testD', 0, 0);$sql$, $sql$SELECT '{"key": true}'::jsonb;$sql$, 'discord.GetSettings must return user settings if called correctly.');
	-- A call for non-existent settings must return null.
	RETURN NEXT results_eq($sql$SELECT discord.GetSettings('testF');$sql$, $sql$SELECT 'null'::jsonb;$sql$, 'discord.GetSettings must return null jsonb if called with invalid arguments.');
END;
$$ LANGUAGE plpgsql;
