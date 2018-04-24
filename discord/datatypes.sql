-- Create enums.
/*
allow - Only allow the types specified.
deny - Do not allow the types specified.
*/
DO $$ BEGIN
	CREATE TYPE discord.accessType AS ENUM ('allow', 'deny');
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
/*
everyone - Applies the method to everyone.
role - Checks the users roles.
channel - Checks the channel that the command was used in.
server - Checks the server that the command was used in.
dm - Checks if the command is being called from a direct message.
*/
DO $$ BEGIN
	CREATE TYPE discord.accessMethod AS ENUM ('dm', 'server', 'everyone', 'channel', 'role');
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
