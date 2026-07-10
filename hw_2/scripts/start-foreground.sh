#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"${HW_DIR}/scripts/format.sh"

mkdir -p "${PROCESS_LOG_DIR}"

echo "Starting Kafka broker/controller in foreground on ${BOOTSTRAP_SERVER}"
exec kafka-server-start.sh "${SERVER_CONFIG}"
