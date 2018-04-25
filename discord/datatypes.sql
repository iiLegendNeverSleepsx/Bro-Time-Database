-- Create enums.
/*
allow - Only allow the types specified.
deny - Do not allow the types specified.
*/
CREATE TYPE discord.accessType AS ENUM ('allow', 'deny');
/*
everyone - Applies the method to everyone.
role - Checks the users roles.
channel - Checks the channel that the command was used in.
server - Checks the server that the command was used in.
dm - Checks if the command is being called from a direct message.
*/
CREATE TYPE discord.accessMethod AS ENUM ('dm', 'server', 'everyone', 'channel', 'role');
