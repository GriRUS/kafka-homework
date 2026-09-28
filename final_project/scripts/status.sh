#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

compose ps
echo
kafka_exec kafka-topics \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --describe
echo
kafka_exec kafka-consumer-groups \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --command-config "${ADMIN_CONFIG}" \
  --all-groups --describe

