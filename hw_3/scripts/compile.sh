#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

mkdir -p "${BUILD_DIR}"

sources=()
while IFS= read -r source_file; do
  sources+=("${source_file}")
done < <(find "${SRC_DIR}" -name '*.java' | sort)

if [[ "${#sources[@]}" -eq 0 ]]; then
  echo "No Java sources found in ${SRC_DIR}"
  exit 1
fi

javac \
  -cp "${KAFKA_HOME}/libs/*" \
  -d "${BUILD_DIR}" \
  "${sources[@]}"

echo "Compiled ${#sources[@]} Java source file(s) into ${BUILD_DIR}"
