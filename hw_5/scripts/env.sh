#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${HW_DIR}/.." && pwd)"

COMPOSE_FILE="${HW_DIR}/compose.yaml"
CONNECT_HOST_PORT="${CONNECT_HOST_PORT:-8083}"
CONNECT_URL="${CONNECT_URL:-http://localhost:${CONNECT_HOST_PORT}}"
CONNECTOR_NAME="${CONNECTOR_NAME:-postgres-clients-cdc}"
CONNECTOR_CONFIG="${CONNECTOR_CONFIG:-${HW_DIR}/config/postgres-cdc-source.json}"
KAFKA_TOPIC="${KAFKA_TOPIC:-postgres.clients}"
MAX_MESSAGES="${MAX_MESSAGES:-4}"
CONSUMER_TIMEOUT_MS="${CONSUMER_TIMEOUT_MS:-30000}"

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose -f "${COMPOSE_FILE}" "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f "${COMPOSE_FILE}" "$@"
  else
    echo "Docker Compose is required. Install Docker Desktop or docker-compose." >&2
    return 1
  fi
}

wait_for_connect() {
  echo "Waiting for Kafka Connect REST API at ${CONNECT_URL}..."
  for _ in {1..90}; do
    if curl -fsS "${CONNECT_URL}/connectors" >/dev/null 2>&1; then
      echo "Kafka Connect is ready"
      return 0
    fi
    sleep 2
  done

  echo "Kafka Connect did not become ready in time. Last Connect logs:"
  compose logs --tail=120 connect || true
  return 1
}

wait_for_connector() {
  echo "Waiting for connector ${CONNECTOR_NAME}..."
  for _ in {1..60}; do
    STATUS="$(curl -fsS "${CONNECT_URL}/connectors/${CONNECTOR_NAME}/status" 2>/dev/null || true)"
    if [[ "${STATUS}" == *'"state":"RUNNING"'* ]] && [[ "${STATUS}" == *'"tasks":[{"id":0,"state":"RUNNING"'* ]]; then
      echo "Connector is running"
      return 0
    fi
    sleep 2
  done

  echo "Connector did not become RUNNING. Current status:"
  curl -fsS "${CONNECT_URL}/connectors/${CONNECTOR_NAME}/status" || true
  echo
  compose logs --tail=120 connect || true
  return 1
}
