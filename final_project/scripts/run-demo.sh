#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

produce() {
  local config="$1"
  local topic="$2"
  local message="$3"
  printf '%s\n' "${message}" | kafka_exec kafka-console-producer \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --producer.config "/etc/kafka/client/${config}.properties" \
    --topic "${topic}" \
    --request-required-acks all
}

consume_one() {
  local config="$1"
  local topic="$2"
  local group="$3"
  kafka_exec kafka-console-consumer \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --consumer.config "/etc/kafka/client/${config}.properties" \
    --topic "${topic}" \
    --group "${group}" \
    --from-beginning \
    --max-messages 1 \
    --timeout-ms 10000
}

expect_denied() {
  local title="$1"
  shift
  set +e
  local output
  output="$("$@" 2>&1)"
  local code=$?
  set -e
  if grep -Eqi 'not authorized|TopicAuthorizationException|GroupAuthorizationException|ClusterAuthorizationException' <<<"${output}"; then
    echo "[OK] ${title}: access denied by ACL"
    return 0
  fi
  echo "[ERROR] ${title}: expected an authorization error (exit ${code})" >&2
  echo "${output}" >&2
  return 1
}

echo "1. order_service writes an order"
produce order-service orders '{"orderId":"order-101","amount":3500}'
echo "[OK] message acknowledged with acks=all"

echo
echo "2. payment_service reads the order and writes a payment"
consume_one payment-service orders payment-service
produce payment-service payments '{"orderId":"order-101","status":"paid"}'
echo "[OK] payment flow completed"

echo
echo "3. auditor reads the payment"
consume_one auditor payments audit-console
echo "[OK] read-only auditor has access"

echo
echo "4. forbidden operations"
expect_denied "guest writes to orders" produce guest orders '{"orderId":"forbidden"}'
expect_denied "order_service reads orders" consume_one order-service orders order-service
expect_denied "auditor writes to payments" produce auditor payments '{"status":"forbidden"}'

echo
echo "All security scenarios passed"
