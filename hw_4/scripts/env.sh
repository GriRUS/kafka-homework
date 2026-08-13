#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${HW_DIR}/.." && pwd)"

export JAVA_HOME="${ROOT_DIR}/.local/jdk"
export KAFKA_HOME="${ROOT_DIR}/.local/kafka_2.13-3.9.2"
export PATH="${JAVA_HOME}/bin:${KAFKA_HOME}/bin:${PATH}"
export LOG_DIR="${HW_DIR}/runtime/process-logs"
export KAFKA_JMX_OPTS="-Dkafka.jmx.disabled=true"
unset JMX_PORT || true

BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-127.0.0.1:9092}"
APPLICATION_ID="${APPLICATION_ID:-hw4-event-session-counter}"
INPUT_TOPIC="${INPUT_TOPIC:-events}"
OUTPUT_TOPIC="${OUTPUT_TOPIC:-event-counts}"
SESSION_GAP_MINUTES="${SESSION_GAP_MINUTES:-5}"
STORE_NAME="event-session-counts-store"
TOPICS=("${INPUT_TOPIC}" "${OUTPUT_TOPIC}")
CLEANUP_TOPICS=(
  "${INPUT_TOPIC}"
  "${OUTPUT_TOPIC}"
  "${APPLICATION_ID}-${STORE_NAME}-changelog"
  "${APPLICATION_ID}-${STORE_NAME}-repartition"
)

SERVER_CONFIG="${HW_DIR}/config/kraft-server.properties"
CLUSTER_ID_FILE="${HW_DIR}/cluster.id"
KAFKA_LOG_DIR="${HW_DIR}/runtime/kraft-logs"
PROCESS_LOG_DIR="${HW_DIR}/runtime/process-logs"
PID_FILE="${PROCESS_LOG_DIR}/server.pid"
APP_PID_FILE="${PROCESS_LOG_DIR}/streams-app.pid"
APP_LOG_FILE="${PROCESS_LOG_DIR}/streams-app.log"
SRC_DIR="${HW_DIR}/src/main/java"
BUILD_DIR="${HW_DIR}/target/classes"
STATE_DIR="${HW_DIR}/runtime/streams-state"
JAVA_PACKAGE="ru.otus.kafka.homework.hw4"
APP_CLASS="${JAVA_PACKAGE}.EventSessionCountApp"
