#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

run() {
  local title="$1"
  shift
  echo
  echo "===== ${title} ====="
  set +e
  "$@"
  local code=$?
  set -e
  echo "exit code: ${code}"
}

produce() {
  local config="$1"
  local message="$2"
  printf '%s\n' "${message}" | kafka-console-producer.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --producer.config "${config}" \
    --topic "${TOPIC_NAME}" \
    --request-required-acks all \
    --producer-property enable.idempotence=false \
    --producer-property max.block.ms=5000
}

consume() {
  local config="$1"
  local group="$2"
  kafka-console-consumer.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --consumer.config "${config}" \
    --topic "${TOPIC_NAME}" \
    --group "${group}" \
    --from-beginning \
    --timeout-ms 7000
}

run "admin: list topics" kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --command-config "${ADMIN_CONFIG}" --list
run "writer: list topics" kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --command-config "${WRITER_CONFIG}" --list
run "reader: list topics" kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --command-config "${READER_CONFIG}" --list
run "guest: list topics" kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --command-config "${GUEST_CONFIG}" --list

run "writer: produce message, expected SUCCESS" produce "${WRITER_CONFIG}" "message from writer"
run "reader: produce message, expected DENIED" produce "${READER_CONFIG}" "message from reader"
run "guest: produce message, expected DENIED" produce "${GUEST_CONFIG}" "message from guest"

run "writer: consume messages, expected DENIED" consume "${WRITER_CONFIG}" writer-group
run "reader: consume messages, expected SUCCESS" consume "${READER_CONFIG}" reader-group
run "guest: consume messages, expected DENIED" consume "${GUEST_CONFIG}" guest-group
