#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/env.sh"

echo "Java:"
java -version
echo
echo "Kafka:"
"$KAFKA_HOME/bin/kafka-topics.sh" --version
echo
echo "Топик test:"
"$KAFKA_HOME/bin/kafka-topics.sh" \
  --bootstrap-server 127.0.0.1:9092 \
  --describe \
  --topic test
