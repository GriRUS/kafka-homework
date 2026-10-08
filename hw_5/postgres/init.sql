CREATE SCHEMA IF NOT EXISTS inventory;

CREATE TABLE IF NOT EXISTS inventory.clients (
  id int PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL,
  gender text NOT NULL,
  card_number text NOT NULL,
  bill numeric(7, 2) NOT NULL DEFAULT 0,
  created_date timestamp NOT NULL DEFAULT current_timestamp(0),
  modified_date timestamp NOT NULL DEFAULT current_timestamp(0)
);

ALTER TABLE inventory.clients REPLICA IDENTITY FULL;
