#!/usr/bin/env bash
set -euo pipefail

api() {
  local method="$1" params="$2"
  curl -sf -X POST "${ZABBIX_URL%/}/api_jsonrpc.php" \
    -H 'Content-Type: application/json-rpc' \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":${params},\"id\":1}"
}

existing_resp=$(api "usergroup.get" "{\"output\":[\"usrgrpid\"],\"filter\":{\"name\":[\"${NAME}\"]}}")
existing_id=$(echo "$existing_resp" | jq -r '.result[0].usrgrpid // empty')

if [ -z "$existing_id" ]; then
  echo "user group '${NAME}' already absent, nothing to delete"
  exit 0
fi

api "usergroup.delete" "[\"${existing_id}\"]" > /dev/null
echo "deleted user group '${NAME}' (usrgrpid ${existing_id})"
