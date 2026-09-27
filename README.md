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
- **Everything else** (hosts, host groups, templates, items, triggers,
  graphs, proxies...) is managed with the standard
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
