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

source_json=$(jq -Rs '.' < "${XML_PATH}")

params=$(jq -n --argjson source "${source_json}" '{
  format: "xml",
  source: $source,
  rules: {
    template_groups:    {createMissing: true, updateExisting: true},
    host_groups:        {createMissing: true, updateExisting: true},
    templates:          {createMissing: true, updateExisting: true},
    templateDashboards: {createMissing: true, updateExisting: true, deleteMissing: false},
    templateLinkage:    {createMissing: true, deleteMissing: false},
    items:              {createMissing: true, updateExisting: true, deleteMissing: false},
    discoveryRules:     {createMissing: true, updateExisting: true, deleteMissing: false},
    triggers:           {createMissing: true, updateExisting: true, deleteMissing: false},
    graphs:             {createMissing: true, updateExisting: true, deleteMissing: false},
    valueMaps:          {createMissing: true, updateExisting: true, deleteMissing: false},
    httptests:          {createMissing: true, updateExisting: true, deleteMissing: false}
  }
}')

resp=$(api "configuration.import" "${params}")
fail_if_error "${resp}"
echo "imported template from ${XML_PATH}"
