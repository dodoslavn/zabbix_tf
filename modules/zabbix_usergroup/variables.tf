variable "zabbix_url" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "name" {
  type        = string
  description = "Exact name of the Zabbix user group"
}
