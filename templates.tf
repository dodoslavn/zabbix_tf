# Template XML lives in a separate repo (dodoslavn/zabbix_templates),
# vendored in here as a git submodule under vendor/zabbix_templates so
# `terraform apply` always imports whatever that repo currently contains.
locals {
  template_xml_files = fileset("${path.module}/vendor/zabbix_templates/templates", "*/template.xml")
}

module "template_import" {
  for_each = local.template_xml_files
  source   = "./modules/zabbix_template_import"

  zabbix_url = var.zabbix_url
  api_token  = var.zabbix_api_token
  xml_path   = "${path.module}/vendor/zabbix_templates/templates/${each.value}"
}
