#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "===== Start Kafka ====="
"${HW_DIR}/scripts/start.sh"

echo
echo "===== Reset topics ====="
"${HW_DIR}/scripts/reset-topics.sh"

echo
echo "===== Run transactional producer ====="
"${HW_DIR}/scripts/run-producer.sh"

echo
echo "===== Run read_committed consumer ====="
"${HW_DIR}/scripts/run-consumer.sh"

echo
echo "Demo finished. Stop Kafka with: ./hw_3/scripts/stop.sh"
