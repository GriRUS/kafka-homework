#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

echo "Reading ${MAX_MESSAGES} message(s) from Kafka topic ${KAFKA_TOPIC}..."
compose exec -T kafka /kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --topic "${KAFKA_TOPIC}" \
  --from-beginning \
  --max-messages "${MAX_MESSAGES}" \
  --timeout-ms "${CONSUMER_TIMEOUT_MS}" \
  --formatter-property print.key=true \
  --formatter-property key.separator=" -> "
