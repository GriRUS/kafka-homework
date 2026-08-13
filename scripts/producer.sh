#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "Введите сообщения по одному на строке. Для выхода нажмите Ctrl+C."
exec "$KAFKA_HOME/bin/kafka-console-producer.sh" \
  --bootstrap-server 127.0.0.1:9092 \
  --topic test
