#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

kafka-server-stop.sh >/dev/null 2>&1 || true

for _ in {1..30}; do
  if ! nc -z 127.0.0.1 9094 >/dev/null 2>&1; then
    echo "Kafka broker stopped"
    exit 0
  fi
  sleep 1
done

echo "Kafka broker may still be stopping"
