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

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/delete.sh"
    environment = {
      ZABBIX_URL = self.triggers.zabbix_url
      API_TOKEN  = var.api_token
      NAME       = self.triggers.name
    }
  }
}
