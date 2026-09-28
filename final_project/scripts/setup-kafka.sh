#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

topics=(orders payments notifications audit-events)

for topic in "${topics[@]}"; do
  kafka_exec kafka-topics \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --command-config "${ADMIN_CONFIG}" \
    --create --if-not-exists \
    --topic "${topic}" \
    --partitions 3 \
    --replication-factor 3 \
    --config min.insync.replicas=2
done

add_topic_acl() {
  local principal="$1"
  local operation="$2"
  local topic="$3"
  kafka_exec kafka-acls \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --command-config "${ADMIN_CONFIG}" \
    --add --allow-principal "User:${principal}" \
    --operation "${operation}" \
    --topic "${topic}" >/dev/null
}

add_group_acl() {
  local principal="$1"
  local operation="$2"
  local group="$3"
  kafka_exec kafka-acls \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --command-config "${ADMIN_CONFIG}" \
    --add --allow-principal "User:${principal}" \
    --operation "${operation}" \
    --group "${group}" >/dev/null
}

# Each application receives only the permissions required by its place in the flow.
add_topic_acl order_service Write orders
add_topic_acl order_service Describe orders

add_topic_acl payment_service Read orders
add_topic_acl payment_service Describe orders
add_group_acl payment_service Read payment-service
add_topic_acl payment_service Write payments
add_topic_acl payment_service Describe payments

add_topic_acl notification_service Read payments
add_topic_acl notification_service Describe payments
add_group_acl notification_service Read notification-service
add_topic_acl notification_service Write notifications
add_topic_acl notification_service Describe notifications

for topic in "${topics[@]}"; do
  add_topic_acl auditor Read "${topic}"
  add_topic_acl auditor Describe "${topic}"
  add_topic_acl monitoring Read "${topic}"
  add_topic_acl monitoring Describe "${topic}"
done
add_group_acl auditor Read audit-console

# kafka-exporter reads metadata and committed offsets, but cannot produce messages.
kafka_exec kafka-acls \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --add --allow-principal User:monitoring \
  --operation Describe --cluster >/dev/null
kafka_exec kafka-acls \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --add --allow-principal User:monitoring \
  --operation Read --group '*' >/dev/null

echo "Topics and ACL rules are ready"

