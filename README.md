# terraform-github-4alvit

Terraform IaC for **4alvit** personal GitHub account infrastructure.

<!-- ci-release-process:start -->
## CI and deployment

See [CI and deployment workflow](docs/release-workflow.md) for required checks and local commands. This repository uses validation-only policy; application release channels do not apply.
<!-- ci-release-process:end -->

## Workspace

Independent repository roots have separate state ownership. Their operating
instructions live beside their configuration; do not add the same remote object
to the top-level state or use an empty state as an access-recovery workaround.

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

### Public repositories

The public catalog is grouped by purpose. Repository contents and deployments
remain the responsibility of their own projects:

- [energy-data-rag-pipeline](https://github.com/4alvit/energy-data-rag-pipeline),
  [mcp-venus-os](https://github.com/4alvit/mcp-venus-os) and
  [solar-forecast-langgraph](https://github.com/4alvit/solar-forecast-langgraph) —
  documentation retrieval, MCP tools and forecasting.
- [mqtt-observability-opentelemetry](https://github.com/4alvit/mqtt-observability-opentelemetry)
  and [fastapi-mqtt-gateway](https://github.com/4alvit/fastapi-mqtt-gateway) — MQTT tooling.
- [esphome-ble-sensor-patterns](https://github.com/4alvit/esphome-ble-sensor-patterns)
  and [dbus-service-template](https://github.com/4alvit/dbus-service-template) — reusable examples.
- [amazon-echo-home-voice](https://github.com/4alvit/amazon-echo-home-voice) and
  [google-home-voice-stats](https://github.com/4alvit/google-home-voice-stats) — energy-report adapters.
- [4alvit](https://github.com/4alvit/4alvit) and
  [iot-project-builder-profile](https://github.com/4alvit/iot-project-builder-profile) — project discovery.
- [terraform-github-victron](https://github.com/4alvit/terraform-github-victron),
  [terraform-github-open-ott-play](https://github.com/4alvit/terraform-github-open-ott-play)
  and [terraform-github-ha-homelab](https://github.com/4alvit/terraform-github-ha-homelab)
  — organization repository settings.

This is a public discovery list, not evidence of complete Terraform state
coverage. Reconcile authorized live inventory with each state before adoption.

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

## Contributions and public security

See [CONTRIBUTING.md](CONTRIBUTING.md) for bug reports, proposed changes and tests,
[SECURITY.md](SECURITY.md) for private vulnerability reports, and
[public security policy](docs/public-security.md) for review requirements,
secret protection and rollout/state ownership. OpenSSF readiness is assessed
for this infrastructure repository separately from the projects it manages.
