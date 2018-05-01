CREATE OR REPLACE FUNCTION discord.AddBot(p_Server_Id bigint) RETURNS void AS $$
BEGIN
    INSERT INTO discord.Servers(Server_Id)
		VALUES(p_Server_Id)
	ON CONFLICT ON CONSTRAINT Servers_Server_Id_PK DO NOTHING;
END;
$$ LANGUAGE plpgsql;
