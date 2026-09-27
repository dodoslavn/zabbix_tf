resource "null_resource" "user" {
  triggers = {
    zabbix_url   = var.zabbix_url
    username     = var.username
    name         = var.name
    surname      = var.surname
    role_name    = var.role_name
    usrgrp_names = join(",", var.usrgrp_names)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/upsert.sh"
    environment = {
      ZABBIX_URL   = self.triggers.zabbix_url
      API_TOKEN    = var.api_token
      USERNAME     = self.triggers.username
      NAME         = self.triggers.name
      SURNAME      = self.triggers.surname
      ROLE_NAME    = self.triggers.role_name
      USRGRP_NAMES = self.triggers.usrgrp_names
      PASSWD       = coalesce(var.passwd, "")
    }
  }

  # Destroy-time provisioners may only reference `self`, so API_TOKEN can't be
  # passed here as var.api_token - the script falls back to reading it from
  # the ambient environment (API_TOKEN or TF_VAR_zabbix_api_token) instead.
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/delete.sh"
    environment = {
      ZABBIX_URL = self.triggers.zabbix_url
      USERNAME   = self.triggers.username
    }
  }
}
