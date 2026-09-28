#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"${HW_DIR}/scripts/compile.sh"

mkdir -p "${STATE_DIR}"

exec java \
  -Dlog4j.configuration="file:${HW_DIR}/config/log4j.properties" \
  -cp "${BUILD_DIR}:${KAFKA_HOME}/libs/*" \
  "${APP_CLASS}" \
  "${BOOTSTRAP_SERVER}" \
  "${INPUT_TOPIC}" \
  "${OUTPUT_TOPIC}" \
  "${SESSION_GAP_MINUTES}" \
  "${STATE_DIR}" \
  "${APPLICATION_ID}"
