#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

compose exec -T postgres psql -U postgres -d inventory -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO inventory.clients (
  id,
  first_name,
  last_name,
  gender,
  card_number,
  bill,
  created_date,
  modified_date
) VALUES
  (1001, 'Ivan', 'Petrov', 'male', '4111111111111111', 5000.00, current_timestamp(0), current_timestamp(0)),
  (1002, 'Anna', 'Sidorova', 'female', '5555555555554444', 7300.50, current_timestamp(0), current_timestamp(0)),
  (1003, 'Pavel', 'Ivanov', 'male', '4012888888881881', 1200.75, current_timestamp(0), current_timestamp(0))
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  gender = EXCLUDED.gender,
  card_number = EXCLUDED.card_number,
  bill = EXCLUDED.bill,
  modified_date = current_timestamp(0);

UPDATE inventory.clients
SET bill = bill + 500,
    modified_date = current_timestamp(0)
WHERE id = 1001;

SELECT * FROM inventory.clients ORDER BY id;
SQL

echo
echo "Rows were written to PostgreSQL. Debezium will stream them to Kafka topic ${KAFKA_TOPIC}."
