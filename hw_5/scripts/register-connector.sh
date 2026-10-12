#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

wait_for_connect

echo "Removing old connector if it exists..."
curl -sS -X DELETE "${CONNECT_URL}/connectors/${CONNECTOR_NAME}" >/dev/null || true
sleep 3

echo "Registering connector from ${CONNECTOR_CONFIG}..."
curl -fsS \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary "@${CONNECTOR_CONFIG}" \
  "${CONNECT_URL}/connectors"
echo

wait_for_connector
