#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"${HW_DIR}/scripts/format.sh"

mkdir -p "${PROCESS_LOG_DIR}"

if nc -z 127.0.0.1 9094 >/dev/null 2>&1; then
  echo "Kafka already listens on ${BOOTSTRAP_SERVER}"
  exit 0
fi

kafka-server-start.sh -daemon "${SERVER_CONFIG}"

echo "Waiting for Kafka broker on ${BOOTSTRAP_SERVER}..."
for _ in {1..60}; do
  if kafka-broker-api-versions.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --command-config "${ADMIN_CONFIG}" >/dev/null 2>&1; then
    echo "Kafka broker is ready: ${BOOTSTRAP_SERVER}"
    exit 0
  fi
  sleep 1
done

echo "Kafka did not become ready in time. Last server log lines:"
tail -80 "${PROCESS_LOG_DIR}/server.log" 2>/dev/null || true
exit 1
