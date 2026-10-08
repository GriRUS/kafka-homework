#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

compose up -d
wait_for_connect

echo
echo "Available connector plugins:"
curl -fsS "${CONNECT_URL}/connector-plugins"
echo
