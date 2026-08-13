#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

exec kafka-console-consumer.sh \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --topic "${OUTPUT_TOPIC}" \
  --from-beginning \
  --property print.key=true \
  --property key.separator=" -> "
