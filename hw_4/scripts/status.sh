#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "Branch: $(git -C "${ROOT_DIR}" branch --show-current)"
echo "Kafka home: ${KAFKA_HOME}"
echo "Java home: ${JAVA_HOME}"
echo "Bootstrap server: ${BOOTSTRAP_SERVER}"
echo "Application id: ${APPLICATION_ID}"
echo "Input topic: ${INPUT_TOPIC}"
echo "Output topic: ${OUTPUT_TOPIC}"
echo "Session gap, minutes: ${SESSION_GAP_MINUTES}"
echo

if [[ -f "${CLUSTER_ID_FILE}" ]]; then
  echo "Cluster UUID: $(tr -d '[:space:]' < "${CLUSTER_ID_FILE}")"
else
  echo "Cluster UUID: not generated yet"
fi

if [[ -s "${PID_FILE}" ]]; then
  echo "Kafka PID: $(tr -d '[:space:]' < "${PID_FILE}")"
else
  echo "Kafka PID: not found"
fi

if [[ -s "${APP_PID_FILE}" ]]; then
  echo "Streams app PID: $(tr -d '[:space:]' < "${APP_PID_FILE}")"
else
  echo "Streams app PID: not found"
fi

echo
kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --list
