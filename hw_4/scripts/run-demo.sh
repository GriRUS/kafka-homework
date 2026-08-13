#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

cleanup() {
  if [[ -s "${APP_PID_FILE}" ]]; then
    APP_PID="$(tr -d '[:space:]' < "${APP_PID_FILE}")"
    if [[ -n "${APP_PID}" ]] && kill -0 "${APP_PID}" >/dev/null 2>&1; then
      kill "${APP_PID}" >/dev/null 2>&1 || true
    fi
    rm -f "${APP_PID_FILE}"
  fi
}
trap cleanup EXIT

echo "===== Start Kafka ====="
"${HW_DIR}/scripts/start.sh"

echo
echo "===== Reset topics ====="
"${HW_DIR}/scripts/reset-topics.sh"

echo
echo "===== Compile and start Kafka Streams app ====="
"${HW_DIR}/scripts/compile.sh"
mkdir -p "${STATE_DIR}"
java \
  -Dlog4j.configuration="file:${HW_DIR}/config/log4j.properties" \
  -cp "${BUILD_DIR}:${KAFKA_HOME}/libs/*" \
  "${APP_CLASS}" \
  "${BOOTSTRAP_SERVER}" \
  "${INPUT_TOPIC}" \
  "${OUTPUT_TOPIC}" \
  "${SESSION_GAP_MINUTES}" \
  "${STATE_DIR}" \
  "${APPLICATION_ID}" > "${APP_LOG_FILE}" 2>&1 &
echo "$!" > "${APP_PID_FILE}"
echo "Kafka Streams app PID: $(cat "${APP_PID_FILE}")"
sleep 8

echo
echo "===== Send events with console producer ====="
printf '%s\n' \
  'user-1:first event' \
  'user-1:second event' \
  'user-2:another event' \
  'user-1:third event' | kafka-console-producer.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --topic "${INPUT_TOPIC}" \
    --property parse.key=true \
    --property key.separator=:

echo
echo "===== Read session count updates ====="
kafka-console-consumer.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --topic "${OUTPUT_TOPIC}" \
  --from-beginning \
  --max-messages 4 \
  --timeout-ms 20000 \
  --property print.key=true \
  --property key.separator=" -> "

echo
echo "===== Kafka Streams app log ====="
tail -40 "${APP_LOG_FILE}" 2>/dev/null || true

echo
echo "Demo finished. Stop Kafka with: ./hw_4/scripts/stop.sh"
