#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "Branch: $(git -C "${ROOT_DIR}" branch --show-current)"
echo "Kafka home: ${KAFKA_HOME}"
echo "Java home: ${JAVA_HOME}"
echo "Bootstrap server: ${BOOTSTRAP_SERVER}"
echo

if [[ -f "${CLUSTER_ID_FILE}" ]]; then
  echo "Cluster UUID: $(tr -d '[:space:]' < "${CLUSTER_ID_FILE}")"
else
  echo "Cluster UUID: not generated yet"
fi

echo
kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --list
