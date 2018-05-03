CREATE OR REPLACE FUNCTION discord.GetSettings(p_Namespace varchar, p_Server_Id bigint, p_User_Id bigint) RETURNS jsonb AS $$
BEGIN
	IF p_Namespace IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Namespace must be provided.';
	END IF;
	
END;
$$
CREATE OR REPLACE FUNCTION discord.SetSettings(p_Namespace varchar, p_Value jsonb, p_Server_Id bigint, p_User_Id bigint) RETURNS jsonb AS $$
BEGIN
	IF p_Namespace IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Namespace must be provided.';
	ELSIF p_Value IS NULL THEN
		RAISE SQLSTATE '22004' USING MESSAGE = 'p_Value must be provided.';
	END IF;
	
END;
$$
