# zabbix_tf

Terraform configuration for the Zabbix instance at monitoring.fordo.eu.

## Split: accounts/groups vs. everything else

No mainstream Zabbix Terraform provider (claranet/zabbix, tpretz/zabbix,
nzolot/zabbix) implements user or user group resources — they only cover
monitoring objects. So this repo is split in two:

- **Users and user groups** (`users.tf`, `groups.tf`) are managed by the
  custom `modules/zabbix_user` and `modules/zabbix_usergroup` modules, which
  call the Zabbix JSON-RPC API directly via `null_resource` + `local-exec`,
  using `curl` and `jq`.
- **Templates** (`templates.tf`) are imported from XML exports rather than
  hand-written as resources — see below.
- **Everything else** (hosts, host groups, items, triggers, graphs,
  proxies...) is managed with the standard
  [`tpretz/zabbix`](https://registry.terraform.io/providers/tpretz/zabbix/latest)
  provider, configured in `main.tf`. Add new resources for these as normal
  Terraform resources — no custom scripting needed.

### Users module behavior

- On `apply`, each instance looks up the user by `username`. If it already
  exists, its name/surname/role/groups are synced to match. If it doesn't
  exist, it's created — this requires `passwd` to be set on that module
  instance.
- On `destroy`, the user is deleted via `user.delete`.

Built-in accounts (`Admin`, `guest`) are intentionally left out of the
managed modules — their aliases are reserved by Zabbix and `guest` cannot be
deleted via the API. They're documented as reference-only data in `users.tf`.

### Groups module behavior

- On `apply`, the group is created if it doesn't already exist by name.
  Existing groups are left untouched (permissions/rights aren't managed by
  this module yet — extend `modules/zabbix_usergroup` if you need that).
- On `destroy`, the group is deleted via `usergroup.delete`.

Built-in groups (`Zabbix administrators`, `Guests`) are documented as
reference-only data in `groups.tf`, not managed.

### Templates module behavior

Template XML lives in a separate repo,
[dodoslavn/zabbix_templates](https://github.com/dodoslavn/zabbix_templates),
vendored in here as a git submodule at `vendor/zabbix_templates`. `templates.tf`
discovers every `templates/*/template.xml` in that submodule and imports each
one via the Zabbix `configuration.import` API — the standard provider has no
resource that accepts raw exported XML, and hand-translating every
template/item/trigger into HCL would just fight the format the templates are
actually maintained in.

- On `apply`, each template is (re-)imported whenever its XML file's content
  changes (tracked via `filemd5`). `createMissing`/`updateExisting` are on for
  templates, items, triggers, graphs, discovery rules, and value maps;
  `deleteMissing` is off everywhere, so removing something from the XML
  doesn't delete it from Zabbix — only the exported repo growing new/changed
  content ever changes anything here.
- There's deliberately no `destroy` behavior: forgetting one of these
  resources from Terraform state must not delete a live template (and
  everything referencing it - hosts, history, triggers). Removing a template
  from Zabbix is a manual, deliberate action.
- Clone with `git submodule update --init` (or `git clone --recurse-submodules`)
  before running `terraform plan`/`apply` locally.

### Prerequisites

- `curl` and `jq` on the machine running `terraform apply`.
- A Zabbix API token with Super Admin permissions, supplied via the
  `zabbix_api_token` variable (e.g. `TF_VAR_zabbix_api_token` env var, never
  committed — see `.gitignore` for `*.tfvars`). This same token authenticates
  both the custom scripts and the `tpretz/zabbix` provider. Destroy-time
  provisioners can't reference Terraform variables, so `terraform destroy`
  reads the token straight from that same `TF_VAR_zabbix_api_token`
  environment variable (or `API_TOKEN`) — make sure it's exported in the
  shell you run `destroy` from.
