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

BOOTSTRAP_SERVER="127.0.0.1:9092"
TOPICS=("topic1" "topic2")
SERVER_CONFIG="${HW_DIR}/config/kraft-server.properties"
CLUSTER_ID_FILE="${HW_DIR}/cluster.id"
KAFKA_LOG_DIR="${HW_DIR}/runtime/kraft-logs"
PROCESS_LOG_DIR="${HW_DIR}/runtime/process-logs"
PID_FILE="${PROCESS_LOG_DIR}/server.pid"
SRC_DIR="${HW_DIR}/src/main/java"
BUILD_DIR="${HW_DIR}/target/classes"
JAVA_PACKAGE="ru.otus.kafka.homework.hw3"
