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

### Security (per repository)
- Vulnerability alerts (`github_repository_vulnerability_alerts`)
- Dependabot security updates (`github_repository_dependabot_security_updates`)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Import Existing Repos

Import blocks are included in `main.tf` for existing repositories. Run:

```bash
terraform init
terraform plan  # Will show imports
```