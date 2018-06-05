CREATE OR REPLACE FUNCTION discord.WalletGet(p_User_Id bigint DEFAULT null) RETURNS integer AS $$
DECLARE
	result integer;
BEGIN
	IF p_User_Id IS NULL THEN
		result := -1;
	ELSE
		result := (SELECT COALESCE((SELECT Amount
			FROM discord.Wallet
			WHERE User_Id = p_User_Id), 0));
	END IF;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION discord.WalletChange(p_Amount integer, p_User_Id bigint DEFAULT null) RETURNS void AS $$
BEGIN
	IF p_Amount IS NULL THEN
		RAISE 'p_Amount must be provided.';
	END IF;
	IF p_User_Id IS NOT NULL THEN
		INSERT INTO discord.Wallet(User_Id, Amount)
		VALUES (p_User_Id, GREATEST(LEAST(p_Amount, 1000000000), 0))
		ON CONFLICT ON CONSTRAINT Wallet_User_Id_PK DO UPDATE
		SET Amount = GREATEST(LEAST(discord.Wallet.Amount + p_Amount, 1000000000), 0);
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION discord.WalletTransfer(p_Amount integer, p_From_User_Id bigint DEFAULT null, p_To_User_Id bigint DEFAULT null) RETURNS void AS $$
BEGIN
	IF p_Amount < 0 THEN
		RAISE 'Can''t transfer back.';
	END IF;
	-- From user.
	IF p_From_User_Id IS NOT NULL THEN
		IF NOT EXISTS (SELECT User_Id FROM discord.Wallet WHERE User_Id = p_From_User_Id) THEN
			RAISE 'No funds available.';
		END IF;
		UPDATE discord.Wallet
		SET Amount = Amount - p_Amount
		WHERE User_Id = p_From_User_Id;
	END IF;
	-- To user.
	IF p_To_User_Id IS NOT NULL THEN
		INSERT INTO discord.Wallet(User_Id, Amount)
		VALUES(p_To_User_Id, ceil(p_Amount - p_Amount*.20))
		ON CONFLICT ON CONSTRAINT Wallet_User_Id_PK DO UPDATE
		SET Amount = GREATEST(LEAST(discord.Wallet.Amount + ceil(p_Amount - p_Amount*.20), 1000000000), 0);
	END IF;
EXCEPTION
	WHEN check_violation THEN
		RAISE 'Not enough funds available.';
END;
$$ LANGUAGE plpgsql;
