# Keep the approved automation account's repository access in desired state.
# These repositories already exist; this resource only manages collaborator access.
resource "github_repository_collaborator" "automation_bot" {
  for_each = toset([
    "4alvit",
    "alvit-meet",
    "amazon-echo-home-voice",
    "cisco-home-telephony",
    "dbus-service-template",
    "demo",
    "energy-data-rag-pipeline",
    "esphome-ble-sensor-patterns",
    "fastapi-mqtt-gateway",
    "github-deploy-webhook",
    "google-home-voice-stats",
    "home-assistant",
    "home-assistant-k3s",
    "house-fiber-atlas",
    "iot-project-builder-profile",
    "k3s-self-healing",
    "mcp-venus-os",
    "mqtt-observability-opentelemetry",
    "solar-forecast-langgraph",
    "terraform-cloudflare-alvit",
    "terraform-github-4alvit",
    "terraform-github-ha-homelab",
    "terraform-github-open-ott-play",
    "terraform-github-victron",
    "terraform-oracle-oci",
    "terraform-portainer-synology",
    "terraform-synology-alvit",
  ])

  repository = each.value
  username   = "californiantiramisu"
  permission = "push"
}
