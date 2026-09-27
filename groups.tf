# Built-in Zabbix groups (Zabbix administrators, Guests) are excluded from
# module management: they're created by Zabbix itself and documented here for
# reference only.
locals {
  builtin_usergroups = [
    "Zabbix administrators",
    "Guests",
  ]
}

module "usergroup_claude_readonly" {
  source = "./modules/zabbix_usergroup"

  zabbix_url = var.zabbix_url
  api_token  = var.zabbix_api_token
  name       = "claude-readonly"
}

module "usergroup_ctv_team" {
  source = "./modules/zabbix_usergroup"

  zabbix_url = var.zabbix_url
  api_token  = var.zabbix_api_token
  name       = "CTV team"
}
