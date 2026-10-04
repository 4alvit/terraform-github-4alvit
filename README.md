# terraform-github-4alvit

Terraform IaC for **4alvit** personal GitHub account infrastructure.

<!-- ci-release-process:start -->
## CI and deployment

See [CI and deployment workflow](docs/release-workflow.md) for required checks and local commands. This repository uses validation-only policy; application release channels do not apply.
<!-- ci-release-process:end -->

## Workspace

The new private `4alvit/claude-harness` repository has its own
[Claude harness repository stack](stacks/claude-harness-repository/README.md)
and HCP workspace `victron-venus/github-claude-harness-repository`. It owns only
that new repository and its two security settings. It does not migrate or
replace the canonical personal state.

The new private `4alvit/terraform-oracle-oci-alvit` repository is managed by the
independent [OCI Alvit repository stack](stacks/oci-alvit-repository/README.md)
in the existing HCP organization `victron-venus`. Its workspace is
`github-oci-alvit-repository`; it owns only that repository and its two security
settings. Use that directory for this deployment. The top-level configuration
and its existing state are separate, as described below.

This project uses the canonical HCP Terraform workspace
`alvit-infrastructure/github-4alvit-infrastructure` for the personal GitHub account.
The workspace ID is `ws-AKy7NQFpKuV5KHyr`. The September 2026 migration recorded
its owner's HCP username as `4alvit`; the operator has since reported renaming
the account. Do not select credentials by that historical username alone.
Verify the token's identity with `GET /api/v2/account/details` and its access to
`GET /api/v2/workspaces/ws-AKy7NQFpKuV5KHyr` before initializing the backend.
A 404 does not distinguish a missing workspace from missing access.

Supply an authorized token through `TF_TOKEN_app_terraform_io` in the command
environment. Load it from a private credential store or hidden input; do not put
it in command history or overwrite another account's default Terraform
credentials. Browser sign-in does not update the CLI token. The GitHub owner
`4alvit` is separate from the editable HCP username.

## Required Variables

Set these in Terraform Cloud workspace variables:

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `github_token` | GitHub Personal Access Token with `repo`, `admin:repo_hook`, `admin:org` scopes for 4alvit account | Yes |
| `github_organization` | GitHub user/org name (default: `4alvit`) | No |

## Managed Resources

### Repositories (All under 4alvit account)
- `alvit-meet` - Private home video calls, TCP/TLS media relay, and WAN DNS updater integration
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
- `claude-harness` - Claude CLI harness (private; owned by the [independent stack](stacks/claude-harness-repository/README.md))
- `terraform-oracle-oci-alvit` - OCI Alvit infrastructure (private; owned by the [independent stack](stacks/oci-alvit-repository/README.md))
- `terraform-cloudflare-alvit` - Terraform for personal Cloudflare free account (zones, DNS, Access, tunnels) (private)
- `amazon-echo-home-voice` - Home Assistant voice control via Amazon Echo (public)
- `google-home-voice-stats` - Home Assistant voice stats via Google Home (public)

- `robinhood` - Private Robinhood MCP server for account analytics and controlled trading; dedicated self-hosted CI runner

### Explicit organization repository exception

- `victron-venus/inverter-climate` - Public energy-aware climate coordination via
  Home Assistant and Victron. The owner explicitly requested management from this
  repository. Its [independent stack](stacks/inverter-climate-repository/README.md)
  uses the HCP workspace `victron-venus/github-inverter-climate-repository`, outside
  the existing personal and organization states. See
  [infrastructure ownership](docs/infrastructure-ownership.md).

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

## RuView home sensing

Private `4alvit/ruview-home-sensing` is owned by the independent
[repository stack](stacks/ruview-home-sensing-repository/README.md).
Its HCP workspace is `victron-venus/github-ruview-home-sensing-repository`;
it does not share resource ownership with the canonical top-level state.
