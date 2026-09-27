# zabbix_tf

Terraform configuration for the Zabbix instance at monitoring.fordo.eu.

## Users

No mainstream Zabbix Terraform provider (claranet/zabbix, tpretz/zabbix, nzolot/zabbix)
implements user or user group resources — they only cover monitoring objects
(hosts, items, triggers, templates). User accounts are therefore managed with a small
`zabbix_user` module (`modules/zabbix_user`) that calls the Zabbix JSON-RPC API
directly via `null_resource` + `local-exec`, using `curl` and `jq`.

Behavior:
- On `apply`, each instance looks up the user by `username`. If it already exists,
  its name/surname/role/groups are updated to match. If it doesn't exist, it's
  created — this requires `passwd` to be set on that module instance.
- On `destroy`, the user is deleted via `user.delete`.

Built-in accounts (`Admin`, `guest`) are intentionally left out of the managed
modules — their aliases are reserved by Zabbix and `guest` cannot be deleted via
the API. They're documented as reference-only data in `users.tf`.

### Prerequisites

- `curl` and `jq` on the machine running `terraform apply`.
- A Zabbix API token with Super Admin permissions, supplied via the
  `zabbix_api_token` variable (e.g. `TF_VAR_zabbix_api_token` env var, never
  committed — see `.gitignore` for `*.tfvars`).
