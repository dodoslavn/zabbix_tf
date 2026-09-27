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

usrgrp_names_json=$(printf '%s' "${USRGRP_NAMES}" | jq -R 'split(",")')

role_resp=$(api "role.get" "{\"output\":[\"roleid\"],\"filter\":{\"name\":[\"${ROLE_NAME}\"]}}")
fail_if_error "$role_resp"
roleid=$(echo "$role_resp" | jq -r '.result[0].roleid // empty')
if [ -z "$roleid" ]; then
  echo "role '${ROLE_NAME}' not found in Zabbix" >&2
  exit 1
fi

usrgrp_resp=$(api "usergroup.get" "{\"output\":[\"usrgrpid\"],\"filter\":{\"name\":${usrgrp_names_json}}}")
fail_if_error "$usrgrp_resp"
usrgrps_json=$(echo "$usrgrp_resp" | jq -c '[.result[] | {usrgrpid: .usrgrpid}]')
if [ "$(echo "$usrgrps_json" | jq 'length')" -eq 0 ]; then
  echo "none of the user groups [${USRGRP_NAMES}] were found in Zabbix" >&2
  exit 1
fi

existing_resp=$(api "user.get" "{\"output\":[\"userid\"],\"filter\":{\"username\":[\"${USERNAME}\"]}}")
fail_if_error "$existing_resp"
existing_userid=$(echo "$existing_resp" | jq -r '.result[0].userid // empty')

if [ -n "$existing_userid" ]; then
  update_resp=$(api "user.update" "{\"userid\":\"${existing_userid}\",\"name\":\"${NAME}\",\"surname\":\"${SURNAME}\",\"roleid\":\"${roleid}\",\"usrgrps\":${usrgrps_json}}")
  fail_if_error "$update_resp"
  echo "updated existing user '${USERNAME}' (userid ${existing_userid})"
else
  if [ -z "${PASSWD}" ]; then
    echo "user '${USERNAME}' does not exist in Zabbix and no passwd was supplied to create it" >&2
    exit 1
  fi
  create_resp=$(api "user.create" "{\"username\":\"${USERNAME}\",\"name\":\"${NAME}\",\"surname\":\"${SURNAME}\",\"roleid\":\"${roleid}\",\"usrgrps\":${usrgrps_json},\"passwd\":\"${PASSWD}\"}")
  fail_if_error "$create_resp"
  echo "created user '${USERNAME}'"
fi
