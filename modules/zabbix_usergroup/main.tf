resource "null_resource" "usergroup" {
  triggers = {
    zabbix_url = var.zabbix_url
    name       = var.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/upsert.sh"
    environment = {
      ZABBIX_URL = self.triggers.zabbix_url
      API_TOKEN  = var.api_token
      NAME       = self.triggers.name
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
      NAME       = self.triggers.name
    }
  }
}
