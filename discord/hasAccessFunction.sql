CREATE OR REPLACE FUNCTION discord.HasAccess(p_command varchar, p_author bigint,
	p_serverId bigint DEFAULT null, p_channelId bigint DEFAULT null, p_roleId bigint DEFAULT null) RETURNS boolean AS $$
DECLARE
	v_result boolean;
    v_rValue record;
	v_rValues cursor(rType discord.accessType) FOR SELECT Restriction_Method RMethod, Ids
		FROM Restrictions
		WHERE Command_Id = p_commandId and
			(Server_Id = null or p_serverId = null or Server_Id = p_serverId) and
			Restriction_Type = rType
		ORDER BY Restriction_Method;
BEGIN
	OPEN v_rValues(discord.accessType.allow);
	LOOP
		FETCH v_rValues INTO v_rValue;
		EXIT WHEN NOT FOUND;
		
		-- Check if allowed. - 'dm', 'server', 'everyone', 'channel', 'role'
		IF v_rValue.RMethod = discord.accessMethod.dm THEN
			v_result := p_serverId = null;
		ELSIF v_rValue.RMethod = discord.accessMethod.server THEN
			v_result := p_serverId = ANY(v_rValue.Ids);
		ELSIF v_rValue.RMethod = discord.accessMethod.everyone THEN
			v_result := true;
		ELSIF v_rValue.RMethod = discord.accessMethod.channel THEN
			v_result := p_channelId = ANY(v_rValue.Ids);
		ELSIF v_rValue.RMethod = discord.accessMethod.role THEN
			v_result := p_roleId = ANY(v_rValue.Ids);
		ELSE
			RAISE WARNING 'discord.HasAccess has no implementation for allowing %.', v_rValue.RMethod USING
				HINT = 'Try replacing the discord.HasAccess function.';
		END IF;
		
		EXIT WHEN v_result = true;
	END LOOP;
	CLOSE v_rValues;
	IF v_result = true THEN
		OPEN v_rValues(discord.accessType.deny);
		LOOP
			FETCH v_rValues INTO v_rValue;
			EXIT WHEN NOT FOUND;
			
			IF v_rValue.RMethod = discord.accessMethod.dm THEN
				v_result := p_serverId != null;
			ELSIF v_rValue.RMethod = discord.accessMethod.server THEN
				v_result := p_serverId != ALL(v_rValue.Ids);
			ELSIF v_rValue.RMethod = discord.accessMethod.everyone THEN
				v_result := false;
			ELSIF v_rValue.RMethod = discord.accessMethod.channel THEN
				v_result := p_channelId != ALL(v_rValue.Ids);
			ELSIF v_rValue.RMethod = discord.accessMethod.role THEN
				v_result := p_roleId != ALL(v_rValue.Ids);
			ELSE
				RAISE WARNING 'discord.HasAccess has no implementation for denying %.', v_rValues.Method USING
					HINT = 'Try replacing the discord.HasAccess function.';
			END IF;
			
			EXIT WHEN v_result = false;
		END LOOP;
		CLOSE v_rValues;
	END IF;
	IF v_result = null THEN
		v_result := false;
	END IF;
	RETURN v_result;
END;
$$ LANGUAGE plpgsql;
