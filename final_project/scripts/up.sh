#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not available. Start Docker and run this script again." >&2
  exit 1
fi

"${SCRIPT_DIR}/generate-certs.sh"
compose up -d --build kafka-1 kafka-2 kafka-3

echo "Waiting for the three Kafka brokers..."
for _ in {1..60}; do
  ready="$(compose ps --format json 2>/dev/null | awk '{ count += gsub(/"Health":"healthy"/, "") } END { print count + 0 }')"
  if [[ "${ready}" -eq 3 ]]; then
    break
  fi
  sleep 3
done

ready="$(compose ps --format json 2>/dev/null | awk '{ count += gsub(/"Health":"healthy"/, "") } END { print count + 0 }')"
if [[ "${ready}" -ne 3 ]]; then
  echo "Kafka did not become healthy. Check: ./final_project/scripts/logs.sh kafka-1" >&2
  exit 1
fi

"${SCRIPT_DIR}/setup-kafka.sh"
compose up -d kafka-exporter prometheus grafana

echo
echo "Kafka cluster is ready"
echo "Grafana:    http://localhost:3000 (admin/admin)"
echo "Prometheus: http://localhost:9090"
echo "Demo:       ./final_project/scripts/run-demo.sh"
