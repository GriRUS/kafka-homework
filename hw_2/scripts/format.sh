#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

mkdir -p "${KAFKA_LOG_DIR}" "${PROCESS_LOG_DIR}"

if [[ ! -s "${CLUSTER_ID_FILE}" ]]; then
  kafka-storage.sh random-uuid > "${CLUSTER_ID_FILE}"
fi

CLUSTER_ID="$(tr -d '[:space:]' < "${CLUSTER_ID_FILE}")"

kafka-storage.sh format \
  --ignore-formatted \
  --cluster-id "${CLUSTER_ID}" \
  --config "${SERVER_CONFIG}"

echo "Cluster UUID: ${CLUSTER_ID}"
echo "Formatted log directory: ${KAFKA_LOG_DIR}"
