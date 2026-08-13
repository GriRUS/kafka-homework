#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "Сообщения топика test с самого начала. Для выхода нажмите Ctrl+C."
exec "$KAFKA_HOME/bin/kafka-console-consumer.sh" \
  --bootstrap-server 127.0.0.1:9092 \
  --topic test \
  --from-beginning \
  --property print.partition=true \
  --property print.offset=true
