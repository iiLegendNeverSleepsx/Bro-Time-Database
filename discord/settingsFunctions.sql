CREATE OR REPLACE FUNCTION discord.SetSettings(p_Namespace varchar, p_Value jsonb, p_Server_Id bigint, p_User_Id bigint) RETURNS json AS $$
BEGIN
	IF p_Namespace IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Namespace must be provided.';
	ELSIF p_Value IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Value must be provided.';
	END IF;
	BEGIN;
	IF p_User_Id IS NULL THEN
		-- Set settings
		INSERT INTO discord.Settings(Namespace, Server_Id, Value)
			VALUES(p_Namespace, p_Server_Id, p_Value)
		ON CONFLICT ON CONSTRAINT Settings_UN DO UPDATE
		SET Value = p_Value;
	ELSE
		-- Set user settings
		INSERT INTO discord.Settings(Namespace, Server_Id)
			VALUES(p_Namespace, p_Server_Id)
		ON CONFLICT ON CONSTRAINT Settings_UN DO NOTHING;
		INSERT INTO discord.User_Settings(Namespace, User_Id, Server_Id, Value)
			VALUES(p_Namespace, p_User_Id, p_Server_Id, p_Value)
		ON CONFLICT ON CONSTRAINT User_Settings_UN DO UPDATE
		SET Value = p_Value;
	END IF;
	COMMIT;
END;
$$
CREATE OR REPLACE FUNCTION discord.GetSettings(p_Namespace varchar, p_Server_Id bigint, p_User_Id bigint) RETURNS json AS $$
DECLARE
	result jsonb;
BEGIN
	IF p_Namespace IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Namespace must be provided.';
	END IF;
	IF p_User_Id IS NULL THEN
		-- Get settings
	ELSE
		-- Get user settings
	END IF;
	RETURN result;
END;
$$