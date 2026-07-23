#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"
cd "${ROOT_DIR}"

"${HW_DIR}/scripts/format.sh"

mkdir -p "${PROCESS_LOG_DIR}"

broker_process_running=false
if [[ -s "${PID_FILE}" ]]; then
  PID="$(tr -d '[:space:]' < "${PID_FILE}")"
  if [[ -n "${PID}" ]] && kill -0 "${PID}" >/dev/null 2>&1; then
    broker_process_running=true
    echo "Kafka broker is already running with PID ${PID}"
  fi
fi

if nc -z 127.0.0.1 9092 >/dev/null 2>&1; then
  echo "Kafka already listens on ${BOOTSTRAP_SERVER}"
elif [[ "${broker_process_running}" == "true" ]]; then
  echo "Kafka process exists; waiting for listener ${BOOTSTRAP_SERVER}"
else
  nohup kafka-server-start.sh "${SERVER_CONFIG}" > "${PROCESS_LOG_DIR}/server.log" 2>&1 < /dev/null &
  echo "$!" > "${PID_FILE}"
  echo "Started Kafka broker/controller with PID $(cat "${PID_FILE}")"
fi

echo "Waiting for Kafka broker on ${BOOTSTRAP_SERVER}..."
for _ in {1..60}; do
  if kafka-broker-api-versions.sh --bootstrap-server "${BOOTSTRAP_SERVER}" >/dev/null 2>&1; then
    echo "Kafka broker is ready: ${BOOTSTRAP_SERVER}"
    exit 0
  fi
  sleep 1
done

echo "Kafka did not become ready in time. Last server log lines:"
tail -80 "${PROCESS_LOG_DIR}/server.log" 2>/dev/null || true
exit 1
