CREATE OR REPLACE FUNCTION discord.HasAccess(command varchar, author bigint,
	serverId bigint DEFAULT null, channelId bigint DEFAULT null, roleId bigint DEFAULT null) RETURNS boolean AS $$
DECLARE
	result boolean;
    rValue record;
	rValues cursor(rType discord.accessType) FOR SELECT Restriction_Method RMethod, Ids
		FROM Restrictions
		WHERE Command_Id = commandId and
			(Server_Id = null or serverId = null or Server_Id = serverId) and
			Restriction_Type = rType
		ORDER BY Restriction_Method;
BEGIN
	OPEN rValues(discord.accessType.allow);
	LOOP
		FETCH rValues INTO rValue;
		EXIT WHEN NOT FOUND;
		
		-- Check if allowed. - 'dm', 'server', 'everyone', 'channel', 'role'
		IF rValue.RMethod = discord.accessMethod.dm THEN
			result := serverId = null;
		ELSIF rValue.RMethod = discord.accessMethod.server THEN
			result := serverId = ANY(rValue.Ids);
		ELSIF rValue.RMethod = discord.accessMethod.everyone THEN
			result := true;
		ELSIF rValue.RMethod = discord.accessMethod.channel THEN
			result := channelId = ANY(rValue.Ids);
		ELSIF rValue.RMethod = discord.accessMethod.role THEN
			result := roleId = ANY(rValue.Ids);
		ELSE
			RAISE WARNING 'discord.HasAccess has no implementation for allowing %.', rValue.RMethod USING
				HINT = 'Try replacing the discord.HasAccess function.';
		END IF;
		
		EXIT WHEN result = true;
	END LOOP;
	CLOSE rValues;
	IF result = true THEN
		OPEN rValues(discord.accessType.deny);
		LOOP
			FETCH rValues INTO rValue;
			EXIT WHEN NOT FOUND;
			
			IF rValue.RMethod = discord.accessMethod.dm THEN
				result := serverId != null;
			ELSIF rValue.RMethod = discord.accessMethod.server THEN
				result := serverId != ALL(rValue.Ids);
			ELSIF rValue.RMethod = discord.accessMethod.everyone THEN
				result := false;
			ELSIF rValue.RMethod = discord.accessMethod.channel THEN
				result := channelId != ALL(rValue.Ids);
			ELSIF rValue.RMethod = discord.accessMethod.role THEN
				result := roleId != ALL(rValue.Ids);
			ELSE
				RAISE WARNING 'discord.HasAccess has no implementation for denying %.', rValues.Method USING
					HINT = 'Try replacing the discord.HasAccess function.';
			END IF;
			
			EXIT WHEN result = false;
		END LOOP;
		CLOSE rValues;
	END IF;
	IF result = null THEN
		result := false;
	END IF;
	RETURN result;
END;
$$ LANGUAGE plpgsql;
