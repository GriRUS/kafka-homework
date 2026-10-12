#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "===== Containers ====="
compose ps

echo
echo "===== Connector status ====="
curl -fsS "${CONNECT_URL}/connectors/${CONNECTOR_NAME}/status" || true
echo

echo
echo "===== Kafka topics ====="
compose exec -T kafka /kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka:9092 \
  --list
