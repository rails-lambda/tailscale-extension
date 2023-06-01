#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -euo pipefail
set +x

# Configuration
OWN_FILENAME="$(basename "$0")"
LAMBDA_EXTENSION_NAME="$OWN_FILENAME" # (external) extension name has to match the filename
TMPFILE="/tmp/tailscale.data"

# Registration
HEADERS="$(mktemp)"
echo "[${LAMBDA_EXTENSION_NAME}] Registering at http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register"
curl -sS -LD "$HEADERS" -XPOST "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register" --header "Lambda-Extension-Name: ${LAMBDA_EXTENSION_NAME}" -d "{ \"events\": [\"SHUTDOWN\"]}" > $TMPFILE

# Extract Extension ID from response headers
RESPONSE=$(<$TMPFILE)
EXTENSION_ID=$(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)
echo "[${LAMBDA_EXTENSION_NAME}] Registration response: ${RESPONSE} with EXTENSION_ID $(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)"

# Start the Tailscale process
echo "[${LAMBDA_EXTENSION_NAME}] Tailscale process..." 1>&2;
/opt/bin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --socket=/tmp/tailscale.sock --state=/tmp/tailscale &
TAILSCALED_PID=$!
echo "[${LAMBDA_EXTENSION_NAME}] TAILSCALED_PID: ${TAILSCALED_PID}" 1>&2;
sleep 1

# Tailscale up
echo "[${LAMBDA_EXTENSION_NAME}] Tailscale up..." 1>&2;
TS_HOSTNAME=${TS_HOSTNAME:-lambda}
if [ "${AWS_LAMBDA_FUNCTION_VERSION}" != '$LATEST' ]; then
  TS_HOSTNAME="${TS_HOSTNAME}-v${AWS_LAMBDA_FUNCTION_VERSION}"
fi
until /opt/bin/tailscale --socket=/tmp/tailscale.sock up --authkey="${TS_KEY}" --hostname="${TS_HOSTNAME}"
do
  sleep 0.1
done
sleep 1

# Waiting for SHUTDOWN event.
while true
do
  echo "[${LAMBDA_EXTENSION_NAME}] Waiting for event. Get /next event from http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next"
  # Get an event. The HTTP request will block until one is received
  curl -sS -L -XGET "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next" --header "Lambda-Extension-Identifier: ${EXTENSION_ID}" > $TMPFILE
  echo "[${LAMBDA_EXTENSION_NAME}] Event received. Processing..."  1>&2;
  EVENT_DATA=$(<$TMPFILE)
  cat $EVENT_DATA 1>&2;
  echo "[${LAMBDA_EXTENSION_NAME}] Calling tailscale down..."  1>&2;
  /opt/bin/tailscale --socket=/tmp/tailscale.sock down
  echo "[${LAMBDA_EXTENSION_NAME}] Sending term to ${TAILSCALED_PID}..."  1>&2;
  kill -TERM "$TAILSCALED_PID" 2>/dev/null
  exit 0
done
