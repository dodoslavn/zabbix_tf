variable "zabbix_url" {
  type        = string
  description = "Base URL of the Zabbix frontend"
  default     = "https://monitoring.fordo.eu"
}

variable "zabbix_api_token" {
  type        = string
  description = "Zabbix API token (Super Admin) used to authenticate JSON-RPC calls for user management"
  sensitive   = true
}
