#!/usr/bin/env bash
set -euo pipefail

api() {
  local method="$1" params="$2"
  curl -sf -X POST "${ZABBIX_URL%/}/api_jsonrpc.php" \
    -H 'Content-Type: application/json-rpc' \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":${params},\"id\":1}"
}

fail_if_error() {
  local response="$1"
  local message
  message=$(echo "$response" | jq -r '.error.data // empty')
  if [ -n "$message" ]; then
    echo "Zabbix API error: ${message}" >&2
    exit 1
  fi
}

existing_resp=$(api "usergroup.get" "{\"output\":[\"usrgrpid\"],\"filter\":{\"name\":[\"${NAME}\"]}}")
fail_if_error "$existing_resp"
existing_id=$(echo "$existing_resp" | jq -r '.result[0].usrgrpid // empty')

if [ -n "$existing_id" ]; then
  echo "user group '${NAME}' already exists (usrgrpid ${existing_id}), leaving permissions untouched"
else
  create_resp=$(api "usergroup.create" "{\"name\":\"${NAME}\"}")
  fail_if_error "$create_resp"
  echo "created user group '${NAME}'"
fi
