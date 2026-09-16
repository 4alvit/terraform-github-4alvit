# terraform-github-4alvit

Terraform IaC for **4alvit** personal GitHub account infrastructure.

<!-- ci-release-process:start -->
## CI and deployment

See [CI and deployment workflow](docs/release-workflow.md) for required checks and local commands. This repository uses validation-only policy; application release channels do not apply.
<!-- ci-release-process:end -->

## Workspace

This project uses the canonical HCP Terraform workspace
`alvit-infrastructure/github-4alvit-infrastructure` for the personal GitHub account.

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
- `terraform-cloudflare-alvit` - Terraform for personal Cloudflare free account (zones, DNS, Access, tunnels) (private)
- `amazon-echo-home-voice` - Home Assistant voice control via Amazon Echo (public)
- `google-home-voice-stats` - Home Assistant voice stats via Google Home (public)

- `robinhood` - Private Robinhood MCP server for account analytics and controlled trading; dedicated self-hosted CI runner

### Security (per repository)
- Vulnerability alerts (`github_repository_vulnerability_alerts`)
- Dependabot security updates (`github_repository_dependabot_security_updates`)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

### Canonical state and backend migration

Keep the `cloud {}` block attached to organization `alvit-infrastructure`,
workspace `github-4alvit-infrastructure`. Every Git worktree uses this same
canonical state. Do not detach the backend or create an independent state owner
for experiments. Run `bash scripts/ci.sh` for validation without backend access.

Existing checkouts may still have backend metadata for
`victron-venus/github-4alvit-infrastructure`. Updating this source does not migrate
remote state or sensitive workspace inputs. Before using the new backend, verify
the protected state backup, destination state lineage and resource identities,
and all workspace inputs, including the separate webhook credential and HMAC.
Coordinate the handoff so only one workspace can apply changes, then reconcile
each checkout's backend metadata with the verified destination. Do not initialize
an empty destination and apply it as a new deployment.

After the handoff, an unrestricted `terraform plan -detailed-exitcode` must report
no changes (exit code `0`). Retire the old workspace only after verifying the
destination and preserving its rollback material. GitHub resources and the
Portainer webhook receiver retain their existing identities and settings; see
[infrastructure ownership](docs/infrastructure-ownership.md).

Never commit credentials, private variable files, saved plans, or state files.
Requires Terraform ≥ 1.15.7.

## Import Existing Repos

Import blocks are included in `main.tf` for existing repositories. Run:

```bash
terraform init
terraform plan  # Will show imports
```
