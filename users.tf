# Built-in Zabbix accounts (Admin, guest) are excluded from module management below:
# their aliases are reserved by Zabbix, cannot be recreated via user.create, and
# guest in particular cannot be deleted via the API. They're documented here for
# reference only.
locals {
  builtin_users = {
    Admin = {
      role   = "Super admin role"
      groups = ["Zabbix administrators"]
    }
    guest = {
      role   = "User role"
      groups = ["Guests"]
    }
  }
}

module "user_claude" {
  source = "./modules/zabbix_user"

  zabbix_url   = var.zabbix_url
  api_token    = var.zabbix_api_token
  username     = "claude"
  name         = "Claude"
  role_name    = "Admin role"
  usrgrp_names = ["claude-readonly"]
}

module "user_ctv" {
  source = "./modules/zabbix_user"

  zabbix_url   = var.zabbix_url
  api_token    = var.zabbix_api_token
  username     = "ctv_user"
  role_name    = "Admin role"
  usrgrp_names = ["CTV team"]
}

module "user_dodo4svk4" {
  source = "./modules/zabbix_user"

  zabbix_url   = var.zabbix_url
  api_token    = var.zabbix_api_token
  username     = "dodo4svk4"
  name         = "Dodoslav"
  role_name    = "Super admin role"
  usrgrp_names = ["Zabbix administrators"]
}
