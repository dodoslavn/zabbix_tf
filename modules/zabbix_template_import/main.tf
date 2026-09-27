# No destroy provisioner here on purpose: forgetting this resource in
# Terraform state should not delete a live Zabbix template (and everything
# that references it - hosts, history, triggers). Removing a template from
# Zabbix, if ever needed, is a deliberate manual action.
resource "null_resource" "template_import" {
  triggers = {
    zabbix_url = var.zabbix_url
    xml_path   = var.xml_path
    file_hash  = filemd5(var.xml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/upsert.sh"
    environment = {
      ZABBIX_URL = self.triggers.zabbix_url
      API_TOKEN  = var.api_token
      XML_PATH   = self.triggers.xml_path
    }
  }
}
