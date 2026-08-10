terraform {

  required_version = ">= 1.15.7"

  # Remote state storage in Terraform Cloud (free tier)
  cloud {
    organization = "victron-venus"

    workspaces {
      name = "github-4alvit-infrastructure"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_organization
  token = var.github_token
}

# =============================================================================
# Repositories (4alvit personal account)
# =============================================================================

resource "github_repository" "energy_data_rag_pipeline" {
  name        = "energy-data-rag-pipeline"
  description = "RAG pipeline for Victron Energy documentation with pgvector, LangChain, and FastAPI"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "fastapi", "langchain", "pgvector", "python", "rag",
    "victron", "energy", "documentation"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "energy_data_rag_pipeline" {
  repository = github_repository.energy_data_rag_pipeline.name
  depends_on = [github_repository.energy_data_rag_pipeline]
}

resource "github_repository_dependabot_security_updates" "energy_data_rag_pipeline" {
  repository = github_repository.energy_data_rag_pipeline.id
  enabled    = true
}

resource "github_repository" "mcp_venus_os" {
  name        = "mcp-venus-os"
  description = "MCP server for Venus OS management - D-Bus, MQTT, and safety-constrained control"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "cerbo-gx", "dbus", "mcp", "mqtt", "python",
    "venus-os", "victron"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "mcp_venus_os" {
  repository = github_repository.mcp_venus_os.name
  depends_on = [github_repository.mcp_venus_os]
}

resource "github_repository_dependabot_security_updates" "mcp_venus_os" {
  repository = github_repository.mcp_venus_os.id
  enabled    = true
}

resource "github_repository" "solar_forecast_langgraph" {
  name        = "solar-forecast-langgraph"
  description = "LangGraph workflow for solar forecasting with weather data, historical generation, panel config, and inverter-control integration"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "langgraph", "python", "solar", "forecast", "weather",
    "victron", "inverter-control"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "solar_forecast_langgraph" {
  repository = github_repository.solar_forecast_langgraph.name
  depends_on = [github_repository.solar_forecast_langgraph]
}

resource "github_repository_dependabot_security_updates" "solar_forecast_langgraph" {
  repository = github_repository.solar_forecast_langgraph.id
  enabled    = true
}

resource "github_repository" "mqtt_observability_opentelemetry" {
  name        = "mqtt-observability-opentelemetry"
  description = "Complete OpenTelemetry observability stack for MQTT-based IoT systems — MQTT message interception with W3C trace context propagation, Mosquitto broker metrics exporter, topic-based span processing, and Grafana/Jaeger/Prometheus visualization. Ready-to-run Docker Compose stack for Venus OS and IoT deployments."
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = true

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "docker", "grafana", "iot", "jaeger", "mqtt", "mqtt-interceptor",
    "observability", "opentelemetry", "prometheus", "python", "tempo",
    "venus-os", "victron"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "mqtt_observability_opentelemetry" {
  repository = github_repository.mqtt_observability_opentelemetry.name
  depends_on = [github_repository.mqtt_observability_opentelemetry]
}

resource "github_repository_dependabot_security_updates" "mqtt_observability_opentelemetry" {
  repository = github_repository.mqtt_observability_opentelemetry.id
  enabled    = true
}

resource "github_repository" "esphome_ble_sensor_patterns" {
  name        = "esphome-ble-sensor-patterns"
  description = "Production-ready patterns for ESPHome BLE sensors — iBeacon, Eddystone, and custom BLE service parsing with lambda filters. Covers ESP32 Bluetooth proxy, passive scanning, and Home Assistant integration for battery-powered sensors."
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "ble", "bluetooth-low-energy", "bluetooth-proxy", "bms", "esp32",
    "esphome", "home-assistant", "ibeacon", "iot", "lambda",
    "passive-scanning", "plant-sensor", "reference-implementation",
    "sensor", "temperature-sensor", "venus-os", "victron", "xiaomi"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "esphome_ble_sensor_patterns" {
  repository = github_repository.esphome_ble_sensor_patterns.name
  depends_on = [github_repository.esphome_ble_sensor_patterns]
}

resource "github_repository_dependabot_security_updates" "esphome_ble_sensor_patterns" {
  repository = github_repository.esphome_ble_sensor_patterns.id
  enabled    = true
}

resource "github_repository" "fastapi_mqtt_gateway" {
  name        = "fastapi-mqtt-gateway"
  description = "Production-ready REST/WebSocket → MQTT bridge"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "fastapi", "mqtt", "rest", "websocket", "gateway",
    "python", "bridge"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "fastapi_mqtt_gateway" {
  repository = github_repository.fastapi_mqtt_gateway.name
  depends_on = [github_repository.fastapi_mqtt_gateway]
}

resource "github_repository_dependabot_security_updates" "fastapi_mqtt_gateway" {
  repository = github_repository.fastapi_mqtt_gateway.id
  enabled    = true
}

resource "github_repository" "dbus_service_template" {
  name        = "dbus-service-template"
  description = "Production-ready Copier template for D-Bus services targeting Victron Venus OS"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "cerbo-gx", "copier", "dbus", "template", "venus-os",
    "victron", "service-template"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "dbus_service_template" {
  repository = github_repository.dbus_service_template.name
  depends_on = [github_repository.dbus_service_template]
}

resource "github_repository_dependabot_security_updates" "dbus_service_template" {
  repository = github_repository.dbus_service_template.id
  enabled    = true
}

resource "github_repository" "profile_4alvit" {
  name        = "4alvit"
  description = "My GitHub profile"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = false
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "profile", "github-profile"
  ]

  license_template = "mit"
}

resource "github_repository" "terraform_github_victron" {
  name        = "terraform-github-victron"
  description = "Terraform IaC for victron-venus GitHub organization infrastructure"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "github", "hcp-terraform", "iac", "infrastructure-as-code",
    "terraform", "victron", "victron-venus"
  ]

  license_template = "mit"
}

resource "github_repository" "home_assistant" {
  name        = "home-assistant"
  description = "Home Assistant configuration"
  visibility  = "private"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "home-assistant", "home-automation", "yaml"
  ]

  license_template = "mit"
}

resource "github_repository" "terraform_github_4alvit" {
  name        = "terraform-github-4alvit"
  description = "Terraform IaC for 4alvit personal GitHub account infrastructure"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "terraform", "github", "iac", "infrastructure-as-code",
    "hcp-terraform", "4alvit"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "terraform_github_4alvit" {
  repository = github_repository.terraform_github_4alvit.name
  depends_on = [github_repository.terraform_github_4alvit]
}

resource "github_repository_dependabot_security_updates" "terraform_github_4alvit" {
  repository = github_repository.terraform_github_4alvit.id
  enabled    = true
}

# iot-project-builder-profile (transferred from victron-venus org)
resource "github_repository" "iot_project_builder_profile" {
  name        = "iot-project-builder-profile"
  description = "Automated engineering profile generator for IoT developers based on GitHub activity"
  visibility  = "public"

  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_discussions = false

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
  allow_auto_merge   = true

  delete_branch_on_merge = true

  topics = [
    "engineering-profile", "esp32", "esphome", "github-api", "iot",
    "llm", "profile-generator", "python"
  ]

  license_template = "mit"
}

resource "github_repository_vulnerability_alerts" "iot_project_builder_profile" {
  repository = github_repository.iot_project_builder_profile.name
  depends_on = [github_repository.iot_project_builder_profile]
}

resource "github_repository_dependabot_security_updates" "iot_project_builder_profile" {
  repository = github_repository.iot_project_builder_profile.id
  enabled    = true
}

# =============================================================================
# Import Blocks (for existing repos)
# =============================================================================

# Repositories
import {
  to = github_repository.energy_data_rag_pipeline
  id = "energy-data-rag-pipeline"
}
import {
  to = github_repository.mcp_venus_os
  id = "mcp-venus-os"
}
import {
  to = github_repository.solar_forecast_langgraph
  id = "solar-forecast-langgraph"
}
import {
  to = github_repository.mqtt_observability_opentelemetry
  id = "mqtt-observability-opentelemetry"
}
import {
  to = github_repository.esphome_ble_sensor_patterns
  id = "esphome-ble-sensor-patterns"
}
import {
  to = github_repository.fastapi_mqtt_gateway
  id = "fastapi-mqtt-gateway"
}
import {
  to = github_repository.dbus_service_template
  id = "dbus-service-template"
}
import {
  to = github_repository.profile_4alvit
  id = "4alvit"
}
import {
  to = github_repository.terraform_github_victron
  id = "terraform-github-victron"
}
import {
  to = github_repository.home_assistant
  id = "home-assistant"
}
import {
  to = github_repository.iot_project_builder_profile
  id = "iot-project-builder-profile"
}

# Vulnerability alerts
import {
  to = github_repository_vulnerability_alerts.energy_data_rag_pipeline
  id = "energy-data-rag-pipeline"
}
import {
  to = github_repository_vulnerability_alerts.mcp_venus_os
  id = "mcp-venus-os"
}
import {
  to = github_repository_vulnerability_alerts.solar_forecast_langgraph
  id = "solar-forecast-langgraph"
}
import {
  to = github_repository_vulnerability_alerts.mqtt_observability_opentelemetry
  id = "mqtt-observability-opentelemetry"
}
import {
  to = github_repository_vulnerability_alerts.esphome_ble_sensor_patterns
  id = "esphome-ble-sensor-patterns"
}
import {
  to = github_repository_vulnerability_alerts.fastapi_mqtt_gateway
  id = "fastapi-mqtt-gateway"
}
import {
  to = github_repository_vulnerability_alerts.dbus_service_template
  id = "dbus-service-template"
}
import {
  to = github_repository_vulnerability_alerts.iot_project_builder_profile
  id = "iot-project-builder-profile"
}

# Dependabot security updates
import {
  to = github_repository_dependabot_security_updates.energy_data_rag_pipeline
  id = "energy-data-rag-pipeline"
}
import {
  to = github_repository_dependabot_security_updates.mcp_venus_os
  id = "mcp-venus-os"
}
import {
  to = github_repository_dependabot_security_updates.solar_forecast_langgraph
  id = "solar-forecast-langgraph"
}
import {
  to = github_repository_dependabot_security_updates.mqtt_observability_opentelemetry
  id = "mqtt-observability-opentelemetry"
}
import {
  to = github_repository_dependabot_security_updates.esphome_ble_sensor_patterns
  id = "esphome-ble-sensor-patterns"
}
import {
  to = github_repository_dependabot_security_updates.fastapi_mqtt_gateway
  id = "fastapi-mqtt-gateway"
}
import {
  to = github_repository_dependabot_security_updates.dbus_service_template
  id = "dbus-service-template"
}
import {
  to = github_repository_dependabot_security_updates.iot_project_builder_profile
  id = "iot-project-builder-profile"
}