#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

if [[ $# -gt 0 ]]; then
  compose logs --tail=150 "$1"
else
  compose logs --tail=150
fi

