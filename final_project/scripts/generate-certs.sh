#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

LOCAL_KEYTOOL="${PROJECT_DIR}/../.local/jdk/bin/keytool"
if [[ -x "${LOCAL_KEYTOOL}" ]]; then
  KEYTOOL="${LOCAL_KEYTOOL}"
elif command -v keytool >/dev/null 2>&1; then
  KEYTOOL="$(command -v keytool)"
else
  echo "Java keytool was not found" >&2
  exit 1
fi

if [[ -f "${SECRETS_DIR}/kafka.keystore.p12" && -f "${SECRETS_DIR}/kafka.truststore.p12" ]]; then
  echo "TLS certificates already exist"
  exit 0
fi

mkdir -p "${SECRETS_DIR}"

openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
  -days 3650 \
  -subj "/CN=Kafka Final Project CA" \
  -keyout "${SECRETS_DIR}/ca.key" \
  -out "${SECRETS_DIR}/ca.crt"

openssl req -newkey rsa:2048 -sha256 -nodes \
  -subj "/CN=kafka" \
  -addext "subjectAltName=DNS:kafka-1,DNS:kafka-2,DNS:kafka-3,DNS:localhost,IP:127.0.0.1" \
  -keyout "${SECRETS_DIR}/broker.key" \
  -out "${SECRETS_DIR}/broker.csr"

openssl x509 -req -sha256 \
  -days 3650 \
  -in "${SECRETS_DIR}/broker.csr" \
  -CA "${SECRETS_DIR}/ca.crt" \
  -CAkey "${SECRETS_DIR}/ca.key" \
  -CAcreateserial \
  -copy_extensions copy \
  -out "${SECRETS_DIR}/broker.crt"

openssl pkcs12 -export \
  -name kafka \
  -in "${SECRETS_DIR}/broker.crt" \
  -inkey "${SECRETS_DIR}/broker.key" \
  -certfile "${SECRETS_DIR}/ca.crt" \
  -password pass:changeit \
  -out "${SECRETS_DIR}/kafka.keystore.p12"

"${KEYTOOL}" -importcert -noprompt \
  -alias kafka-ca \
  -file "${SECRETS_DIR}/ca.crt" \
  -keystore "${SECRETS_DIR}/kafka.truststore.p12" \
  -storetype PKCS12 \
  -storepass changeit

chmod 0644 "${SECRETS_DIR}"/*.crt "${SECRETS_DIR}"/*.p12
echo "TLS certificates created in ${SECRETS_DIR}"
