#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/env.sh"

"$KAFKA_HOME/bin/kafka-server-stop.sh" 2>/dev/null || true
for _ in {1..15}; do
  if ! lsof -nP -iTCP:9092 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

"$KAFKA_HOME/bin/zookeeper-server-stop.sh" 2>/dev/null || true
for _ in {1..15}; do
  if ! lsof -nP -iTCP:2181 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "Kafka Broker и ZooKeeper остановлены"
