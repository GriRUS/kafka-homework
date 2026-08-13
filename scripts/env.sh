#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT_DIR
export JAVA_HOME="$ROOT_DIR/.local/jdk"
export KAFKA_HOME="$ROOT_DIR/.local/kafka"
export PATH="$JAVA_HOME/bin:$KAFKA_HOME/bin:$PATH"

if [[ ! -x "$JAVA_HOME/bin/java" ]]; then
  echo "JDK не найден: $JAVA_HOME" >&2
  exit 1
fi

if [[ ! -x "$KAFKA_HOME/bin/kafka-topics.sh" ]]; then
  echo "Kafka не найдена: $KAFKA_HOME" >&2
  exit 1
fi
