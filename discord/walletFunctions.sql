CREATE OR REPLACE FUNCTION discord.WalletGet(bigint p_User_Id DEFAULT null) RETURNS integer AS $$
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

CREATE OR REPLACE FUNCTION discord.WalletChange(bigint p_User_Id DEFAULT null, integer p_Amount) RETURNS void AS $$
BEGIN
	IF p_User_Id IS NOT NULL THEN
		INSERT INTO discord.Wallet(User_Id, Amount)
		VALUES (p_User_Id, GREATEST(LEAST(p_Amount, 1000000000), 0))
		ON CONFLICT ON CONSTRAINT Wallet_User_Id_PK DO UPDATE
		SET Amount = GREATEST(LEAST(discord.Wallet.Amount + p_Amount, 1000000000), 0);
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION discord.WalletTransfer(bigint p_From_User_Id DEFAULT null, bigint p_To_User_Id DEFAULT null, p_Amount integer) RETURNS void AS $$
DECLARE
	bigint swap;
BEGIN
	-- Swap if transfering back.
	IF p_Amount < 0 THEN
		swap := p_From_User_Id;
		p_From_User_Id := p_To_User_Id;
		p_To_User_Id := swap;
		p_Amount := abs(p_Amount);
	END IF;
	BEGIN;
	-- From user.
	IF p_From_User_Id IS NOT NULL THEN
		IF NOT EXISTS () THEN
			RAISE 'No funds';
		END IF;
		UPDATE discord.Wallet
		SET Amount = Amount - p_Amount
		WHERE User_Id = p_From_User_Id;
	END IF;
	-- To user.
	IF p_To_User_Id IS NOT NULL THEN
		INSERT INTO discord.Wallet(User_Id, Amount)
		VALUES(p_To_User_Id, p_Amount)
		ON CONFLICT ON CONSTRAINT Wallet_User_Id_PK DO UPDATE
		SET Amount = GREATEST(LEAST(discord.Wallet.Amount + p_Amount, 1000000000), 0);
	END IF;
	COMMIT;
EXCEPTION
	WHEN check_violation THEN
		RAISE 'Not enough funds';
END;
$$ LANGUAGE plpgsql;
