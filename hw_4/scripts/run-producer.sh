#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "Enter messages as key:value, for example:"
echo "user-1:first event"
echo "user-1:second event"
echo "Press Ctrl+D to finish."
echo

exec kafka-console-producer.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --topic "${INPUT_TOPIC}" \
  --property parse.key=true \
  --property key.separator=:
