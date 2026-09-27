terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    zabbix = {
      source  = "tpretz/zabbix"
      version = "~> 2.0"
    }
  }
}

# Hosts, host groups, templates, items, triggers, graphs, etc. are managed
# through this standard provider. Accounts and user groups are not supported
# by it (or any other maintained Zabbix provider) and are instead managed via
# the custom zabbix_user / zabbix_usergroup modules calling the API directly.
provider "zabbix" {
  url   = "${var.zabbix_url}/api_jsonrpc.php"
  token = var.zabbix_api_token
}
