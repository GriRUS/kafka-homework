#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

for topic in "${TOPICS[@]}"; do
  kafka-topics.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions 1 \
    --replication-factor 1
done

echo
echo "Current topics:"
kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --list
