variable "zabbix_url" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "xml_path" {
  type        = string
  description = "Absolute path to a Zabbix template export XML file"
}
