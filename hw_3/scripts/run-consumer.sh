#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

"${HW_DIR}/scripts/compile.sh"

java \
  -Dlog4j.configuration="file:${HW_DIR}/config/log4j.properties" \
  -cp "${BUILD_DIR}:${KAFKA_HOME}/libs/*" \
  "${JAVA_PACKAGE}.ReadCommittedConsumerApp" \
  "${BOOTSTRAP_SERVER}"
