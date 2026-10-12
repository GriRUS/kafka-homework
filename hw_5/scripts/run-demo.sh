#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "===== Reset Docker Compose stack ====="
compose down -v --remove-orphans >/dev/null 2>&1 || true

echo
echo "===== Start Kafka, PostgreSQL, Kafka Connect ====="
"${HW_DIR}/scripts/up.sh"

echo
echo "===== Register Debezium PostgreSQL CDC Source Connector ====="
"${HW_DIR}/scripts/register-connector.sh"

echo
echo "===== Insert rows into PostgreSQL ====="
"${HW_DIR}/scripts/insert-records.sh"

echo
echo "===== Connector and topic status ====="
"${HW_DIR}/scripts/status.sh"

echo
echo "===== Read CDC events from Kafka ====="
sleep 5
"${HW_DIR}/scripts/consume.sh"

echo
echo "Demo finished. Stop and clean the stack with: ./hw_5/scripts/down.sh"
