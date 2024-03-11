CREATE UNLOGGED TABLE
  clients (
    "id" SERIAL PRIMARY KEY,
    "limit" INTEGER NOT NULL,
    "balance" INTEGER NOT NULL DEFAULT 0
  );

CREATE UNLOGGED TABLE
  transactions (
    "id" SERIAL PRIMARY KEY,
    "client_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "operation" CHAR(1) NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_transactions_client_id FOREIGN KEY (client_id) REFERENCES clients (id)
  );

ALTER TABLE
  transactions
SET
  (autovacuum_enabled = false);

CREATE INDEX index_transactions_client_id ON transactions (client_id asc);

CREATE OR REPLACE FUNCTION credit(
	client_id INT,
	amount_tran INT,
	description_tran VARCHAR(10))
RETURNS TABLE (
	new_balance INT,
	success BOOL,
	current_limit INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(client_id);

	INSERT INTO transactions VALUES(DEFAULT, client_id, amount_tran, 'c', description_tran);

	RETURN QUERY
		UPDATE clients
		SET balance = balance + amount_tran
		WHERE id = client_id
		RETURNING balance, TRUE, "limit";
END;
$$;

CREATE OR REPLACE FUNCTION debit(
	client_id INT,
	amount_tran INT,
	description_tran VARCHAR(10))
RETURNS TABLE (
	new_balance INT,
	success BOOL,
	current_limit INT)
LANGUAGE plpgsql
AS $$
DECLARE
	current_balance int;
	current_limit int;
BEGIN
	PERFORM pg_advisory_xact_lock(client_id);

	SELECT
		"limit",
		balance
	INTO
		current_limit,
		current_balance
	FROM clients
	WHERE id = client_id;

	IF current_balance - amount_tran >= current_limit * -1 THEN
		INSERT INTO transactions VALUES(DEFAULT, client_id, amount_tran, 'd', description_tran);

		RETURN QUERY
    UPDATE clients
    SET balance = balance - amount_tran
    WHERE id = client_id
    RETURNING balance, TRUE, "limit";

	ELSE
		RETURN QUERY SELECT current_balance, FALSE, current_limit;
	END IF;
END;
$$;

DO
  $$ BEGIN INSERT INTO clients ("id", "limit")
VALUES
  (1, 100000),
  (2, 80000),
  (3, 1000000),
  (4, 10000000),
  (5, 500000);
END;
$$