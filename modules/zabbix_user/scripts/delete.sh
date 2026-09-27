#!/usr/bin/env bash
set -euo pipefail

api() {
  local method="$1" params="$2"
  curl -sf -X POST "${ZABBIX_URL%/}/api_jsonrpc.php" \
    -H 'Content-Type: application/json-rpc' \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":${params},\"id\":1}"
}

existing_resp=$(api "user.get" "{\"output\":[\"userid\"],\"filter\":{\"username\":[\"${USERNAME}\"]}}")
existing_userid=$(echo "$existing_resp" | jq -r '.result[0].userid // empty')

if [ -z "$existing_userid" ]; then
  echo "user '${USERNAME}' already absent, nothing to delete"
  exit 0
fi

api "user.delete" "[\"${existing_userid}\"]" > /dev/null
echo "deleted user '${USERNAME}' (userid ${existing_userid})"
