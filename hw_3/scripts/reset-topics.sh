#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

for topic in "${TOPICS[@]}"; do
  kafka-topics.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --delete \
    --if-exists \
    --topic "${topic}" >/dev/null 2>&1 || true
done

echo "Waiting for topic deletion..."
for _ in {1..30}; do
  all_deleted=true
  for topic in "${TOPICS[@]}"; do
    if kafka-topics.sh \
      --bootstrap-server "${BOOTSTRAP_SERVER}" \
      --describe \
      --topic "${topic}" >/dev/null 2>&1; then
      all_deleted=false
      break
    fi
  done

  if [[ "${all_deleted}" == "true" ]]; then
    break
  fi

  sleep 1
done

"${HW_DIR}/scripts/create-topics.sh"
