variable "zabbix_url" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "username" {
  type        = string
  description = "Zabbix login (username field, formerly 'alias')"
}

variable "name" {
  type    = string
  default = ""
}

variable "surname" {
  type    = string
  default = ""
}

variable "role_name" {
  type        = string
  description = "Exact name of the Zabbix user role, e.g. 'Admin role'"
}

variable "usrgrp_names" {
  type        = list(string)
  description = "Exact names of the Zabbix user groups this user belongs to"
}

variable "passwd" {
  type        = string
  default     = null
  sensitive   = true
  description = "Only used the first time this account is created; ignored for accounts that already exist in Zabbix"
}
