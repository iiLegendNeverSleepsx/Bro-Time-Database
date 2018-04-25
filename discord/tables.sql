-- Create the tables.
CREATE TABLE discord.Settings (
	Namespace varchar(32)
		CONSTRAINT Settings_Namespace_PK PRIMARY KEY
		CONSTRAINT Settings_Namespace_C CHECK (Namespace SIMILAR TO '[a-zA-Z]'),
	Value jsonb
		CONSTRAINT Settings_Value_NN NOT NULL
		CONSTRAINT Settings_Value_C CHECK (pg_column_size(Value) <= 128160)
);

CREATE TABLE discord.User_Settings (
	User_Id bigint,
	Value jsonb
		CONSTRAINT User_Settings_Value_NN NOT NULL
		CONSTRAINT User_Settings_Value_C CHECK (pg_column_size(Value) <= 128160),
	Namespace varchar(32)
    	CONSTRAINT User_Settings_Namepsace_FK REFERENCES discord.Settings(Namespace),
	CONSTRAINT User_Settings_PK PRIMARY KEY (User_Id, Namespace)
);

CREATE TABLE discord.Triggers (
	Trigger_Id varchar(32)
    	CONSTRAINT Triggers_Trigger_Id_C CHECK (Trigger_Id SIMILAR TO '[a-zA-Z]'),
	Event_Id varchar(32)
		CONSTRAINT Triggers_EVENT_Id_NN NOT NULL
		CONSTRAINT Triggers_Event_Id_C CHECK (Event_Id SIMILAR TO '[a-zA-Z]'),
	Event_Parameters varchar(1024)
		CONSTRAINT Triggers_Event_Parameters_N NULL,
	Response_Id varchar(32)
		CONSTRAINT Triggers_Response_Id_NN NOT NULL
		CONSTRAINT Triggers_Response_Id_C CHECK (Response_Id SIMILAR TO '[a-zA-Z]'),
	Response_Parameters varchar(1024)
		CONSTRAINT Triggers_Response_Parameters_N NULL,
	Server_Id bigint,
	CONSTRAINT Triggers_PK PRIMARY KEY (Trigger_Id, Server_Id)
);

CREATE TABLE discord.Servers (
	Server_Id bigint
		CONSTRAINT Servers_Server_Id_PK PRIMARY KEY,
	Prefix varchar(32) DEFAULT '/'
		CONSTRAINT Servers_Prefix_NN NOT NULL,
    Trigger_Id varchar(32)
    	CONSTRAINT Servers_Trigger_Id_N NULL,
    Command_Id varchar(32)
    	CONSTRAINT Servers_Command_Id_N NULL,
    CONSTRAINT Servers_Triggers_FK FOREIGN KEY (Trigger_Id, Server_Id) REFERENCES discord.Triggers(Trigger_Id, Server_Id)
);

CREATE TABLE discord.Restrictions (
	Restriction_Type discord.accessType,
	Restriction_Method discord.accessMethod,
	Ids bigint[]
		CONSTRAINT Restrictions_Ids_NN NOT NULL
		CONSTRAINT Restrictions_Ids_C CHECK (array_length(Ids, 1) <= 1000),
	Command_Id varchar(32),
    Server_Id bigint,
	CONSTRAINT Restrictions_PK PRIMARY KEY (Restriction_Type, Restriction_Method, Command_Id)
);

CREATE TABLE discord.Commands (
	Command_Id varchar(32)
    	CONSTRAINT Commands_Command_Id_PK PRIMARY KEY
    	CONSTRAINT Commands_Command_Id_C CHECK (Command_Id SIMILAR TO '[a-zA-Z]'),
    Restriction_Type discord.accessType
    	CONSTRAINT Commands_Restriction_Type_NN NOT NULL,
    Restriction_Method discord.accessMethod
    	CONSTRAINT Commands_Restriction_Method_NN NOT NULL,
    Server_Id bigint
    	CONSTRAINT Commands_Servers_FK REFERENCES discord.Servers(Server_Id)
    	CONSTRAINT Commands_Server_Id_N NULL,
    CONSTRAINT Commands_Restrictions_FK FOREIGN KEY (Command_Id, Restriction_Type, Restriction_Method) REFERENCES discord.Restrictions(Command_Id, Restriction_Type, Restriction_Method)
);

ALTER TABLE discord.Restrictions
	ADD CONSTRAINT Restrictions_Servers_FK FOREIGN KEY (Server_Id) REFERENCES discord.Servers(Server_Id);
