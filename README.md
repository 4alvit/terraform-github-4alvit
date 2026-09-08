# terraform-github-4alvit

Terraform IaC for **4alvit** personal GitHub account infrastructure.

## Workspace

This project uses HCP Terraform (Terraform Cloud) with workspace: `github-4alvit-infrastructure`

## Required Variables

Set these in Terraform Cloud workspace variables:

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `github_token` | GitHub Personal Access Token with `repo`, `admin:repo_hook`, `admin:org` scopes for 4alvit account | Yes |
| `github_organization` | GitHub user/org name (default: `4alvit`) | No |

## Managed Resources

### Repositories (All under 4alvit account)
- `energy-data-rag-pipeline` - RAG pipeline for Victron Energy docs
- `mcp-venus-os` - MCP server for Venus OS management
- `solar-forecast-langgraph` - LangGraph solar forecasting workflow
- `mqtt-observability-opentelemetry` - OpenTelemetry/Prometheus for Venus OS
- `esphome-ble-sensor-patterns` - ESPHome BLE sensor patterns
- `fastapi-mqtt-gateway` - REST/WebSocket → MQTT bridge
- `dbus-service-template` - Copier template for D-Bus services
- `4alvit` - GitHub profile repo
- `terraform-github-victron` - Terraform for victron-venus org
- `home-assistant` - Home Assistant config (private)
- `github-deploy-webhook` - GitHub deploy webhook + CF Tunnel (private; Cerbo/Synology/Portainer)
- `k3s-self-healing` - Private k3s home cluster provisioning (h5/h7/h8, IRC eggdrop/psybnc/znc)
- `home-assistant-k3s` - Private HA Supervised→k3s migration (pajikos Helm + companions)
- `terraform-portainer-synology` - Terraform for Synology Docker stacks via Portainer (private)
- `terraform-oracle-oci` - Terraform for Oracle Cloud home lab (VCN, SL, h5/h7/h8) (private)

### Security (per repository)
- Vulnerability alerts (`github_repository_vulnerability_alerts`)
- Dependabot security updates (`github_repository_dependabot_security_updates`)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

### Running locally (disconnect from Terraform Cloud)

Use this when you want `terraform plan` / `apply` on your machine **without** HCP Terraform remote execution or remote state.

This repo’s `cloud {}` block in `main.tf` targets organization `victron-venus`, workspace `github-4alvit-infrastructure`.

#### Temporary detach (recommended for experiments)

1. Comment out the entire `cloud { ... }` block in `main.tf`.
2. Clear the local backend cache from the repo root:
   ```bash
   rm -rf .terraform
   ```
3. Re-init (local state by default):
   ```bash
   terraform init
   ```
4. Provide variables locally — TFC workspace variables are **not** used when detached:
   ```bash
   cp terraform.tfvars.example terraform.tfvars   # if present; edit; gitignored
   # or: export TF_VAR_github_token=...  TF_VAR_github_organization=4alvit
   terraform plan
   terraform apply
   ```

#### Keep existing remote state locally (optional)

While still attached to TFC:

```bash
terraform state pull > terraform.tfstate
```

Then comment out `cloud {}` in `main.tf`, `rm -rf .terraform`, `terraform init`, and confirm with `terraform state list`. Keep `terraform.tfstate` **gitignored** — never commit it.

#### Warnings

- Do not apply from both TFC and local against the same resources without coordinating state (drift / conflicts).
- To re-enable TFC: uncomment `cloud {}`, remove local `.terraform` (and local state if migrating back), then `terraform init`. Only `state push` / migrate if you know what you are doing.
- Never commit credentials, `terraform.tfvars` with secrets, or state files.

Requires Terraform ≥ 1.5 (HCP Terraform `cloud {}` block; not the old `backend "remote"` syntax).

## Import Existing Repos

Import blocks are included in `main.tf` for existing repositories. Run:

```bash
terraform init
terraform plan  # Will show imports
```
