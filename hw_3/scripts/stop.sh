#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

if [[ ! -s "${PID_FILE}" ]]; then
  echo "No PID file found for hw_3 Kafka broker"
  exit 0
fi

PID="$(tr -d '[:space:]' < "${PID_FILE}")"

if [[ -z "${PID}" ]] || ! kill -0 "${PID}" >/dev/null 2>&1; then
  echo "Kafka broker is not running"
  rm -f "${PID_FILE}"
  exit 0
fi

kill "${PID}"

for _ in {1..30}; do
  if ! kill -0 "${PID}" >/dev/null 2>&1; then
    rm -f "${PID_FILE}"
    echo "Kafka broker stopped"
    exit 0
  fi
  sleep 1
done

echo "Kafka broker did not stop gracefully; PID ${PID} is still running"
exit 1
