#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --create \
  --if-not-exists \
  --topic "${TOPIC_NAME}" \
  --partitions 1 \
  --replication-factor 1

# writer can write to topic test.
kafka-acls.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --add \
  --allow-principal User:writer \
  --operation Write \
  --topic "${TOPIC_NAME}"

# reader can read topic test and use its consumer group.
kafka-acls.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --add \
  --allow-principal User:reader \
  --operation Read \
  --topic "${TOPIC_NAME}"

kafka-acls.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --add \
  --allow-principal User:reader \
  --operation Read \
  --group reader-group

echo
echo "Current ACLs:"
kafka-acls.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --list
