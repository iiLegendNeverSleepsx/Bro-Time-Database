CREATE FUNCTION test.AddBot() RETURNS setof text AS $$
BEGIN
	-- Throws if arguments are null.
	RETURN NEXT throws_ok('SELECT discord.AddBot(null) FOR UPDATE;', '22004', 'discord.AddBot should not accept null arguments.');
	-- Creates a Servers record.
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called correctly.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0;',  'discord.AddBot must have added a Servers record.');
	-- Does not create another record if called again.
	RETURN NEXT lives_ok('SELECT discord.AddBot(0) FOR UPDATE;', 'discord.AddBot must not throw if called again.');
	RETURN NEXT results_eq('SELECT Server_Id FROM discord.Servers WHERE Server_Id = 0;', 'SELECT 0;',  'discord.AddBot must keep existing Servers records.');
END;
$$ LANGUAGE plpgsql;
