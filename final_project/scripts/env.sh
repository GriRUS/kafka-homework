#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SECRETS_DIR="${PROJECT_DIR}/runtime/secrets"
BOOTSTRAP_SERVER="kafka-1:29092"
ADMIN_CONFIG="/etc/kafka/client/admin.properties"

compose() {
  docker compose --project-directory "${PROJECT_DIR}" -f "${PROJECT_DIR}/compose.yaml" "$@"
}

kafka_exec() {
  compose exec -T -e KAFKA_OPTS= kafka-1 "$@"
}
