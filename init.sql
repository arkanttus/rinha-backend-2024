CREATE TABLE
  clients (
    "id" SERIAL PRIMARY KEY,
    "limit" INTEGER NOT NULL,
    "balance" INTEGER NOT NULL DEFAULT 0
  );

CREATE OR REPLACE FUNCTION validar_saldo()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NEW.balance >= NEW.limit * -1;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE
  clients
ADD CONSTRAINT limit_balance_check CHECK (validar_saldo());

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