#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${HW_DIR}/.." && pwd)"

export JAVA_HOME="${ROOT_DIR}/.local/jdk"
export KAFKA_HOME="${ROOT_DIR}/.local/kafka_2.13-3.9.2"
export PATH="${JAVA_HOME}/bin:${KAFKA_HOME}/bin:${PATH}"
export LOG_DIR="${HW_DIR}/runtime/process-logs"

BOOTSTRAP_SERVER="127.0.0.1:9094"
TOPIC_NAME="test"
SERVER_CONFIG="${HW_DIR}/config/kraft-server.properties"
CLUSTER_ID_FILE="${HW_DIR}/cluster.id"
KAFKA_LOG_DIR="${HW_DIR}/runtime/kraft-logs-sasl-controller"
PROCESS_LOG_DIR="${HW_DIR}/runtime/process-logs"

ADMIN_CONFIG="${HW_DIR}/config/clients/admin.properties"
WRITER_CONFIG="${HW_DIR}/config/clients/writer.properties"
READER_CONFIG="${HW_DIR}/config/clients/reader.properties"
GUEST_CONFIG="${HW_DIR}/config/clients/guest.properties"
