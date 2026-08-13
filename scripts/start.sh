#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT_DIR"

mkdir -p .runtime/zookeeper .runtime/kafka-logs logs

wait_for_port() {
  local port="$1"
  local service="$2"
  local timeout_seconds="${3:-30}"

  for ((second = 0; second < timeout_seconds; second++)); do
    if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "$service запущен на 127.0.0.1:$port"
      return 0
    fi
    sleep 1
  done

  echo "$service не запустился. Проверьте файлы в $ROOT_DIR/logs" >&2
  return 1
}

start_kafka_broker() {
  for attempt in 1 2; do
    LOG_DIR="$ROOT_DIR/logs" \
      "$KAFKA_HOME/bin/kafka-server-start.sh" -daemon \
      "$ROOT_DIR/config/server.properties"

    if wait_for_port 9092 "Kafka Broker" 20; then
      return 0
    fi

    if [[ "$attempt" == "1" ]]; then
      echo "Повторяю запуск после истечения старой ZooKeeper-сессии..."
    fi
  done

  return 1
}

wait_for_kafka_api() {
  for _ in {1..30}; do
    if "$KAFKA_HOME/bin/kafka-broker-api-versions.sh" \
      --bootstrap-server 127.0.0.1:9092 >/dev/null 2>&1; then
      echo "Kafka API готово к работе"
      return 0
    fi
    sleep 1
  done

  echo "Порт 9092 открыт, но Kafka API не отвечает. Проверьте $ROOT_DIR/logs" >&2
  return 1
}

if lsof -nP -iTCP:2181 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "ZooKeeper уже запущен на 127.0.0.1:2181"
else
  LOG_DIR="$ROOT_DIR/logs" \
    "$KAFKA_HOME/bin/zookeeper-server-start.sh" -daemon \
    "$ROOT_DIR/config/zookeeper.properties"
  wait_for_port 2181 ZooKeeper
fi

if lsof -nP -iTCP:9092 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Kafka Broker уже запущен на 127.0.0.1:9092"
else
  start_kafka_broker
fi

wait_for_kafka_api
