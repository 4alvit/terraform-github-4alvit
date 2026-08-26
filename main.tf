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
provider "github" {
  owner = var.github_organization
  token = var.github_token
# =============================================================================
# Repositories (4alvit personal account)
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
resource "github_repository_vulnerability_alerts" "energy_data_rag_pipeline" {
  repository = github_repository.energy_data_rag_pipeline.name
  depends_on = [github_repository.energy_data_rag_pipeline]
resource "github_repository_dependabot_security_updates" "energy_data_rag_pipeline" {
  repository = github_repository.energy_data_rag_pipeline.id
  enabled    = true
resource "github_pages" "iot_project_builder_profile" {
  repository = github_repository.iot_project_builder_profile.name
  source {
    branch = "main"
    path   = "/docs"
resource "github_repository" "mcp_venus_os" {
  name        = "mcp-venus-os"
  description = "MCP server for Venus OS management - D-Bus, MQTT, and safety-constrained control"
    "cerbo-gx", "dbus", "mcp", "mqtt", "python",
    "venus-os", "victron"
resource "github_repository_vulnerability_alerts" "mcp_venus_os" {
  repository = github_repository.mcp_venus_os.name
  depends_on = [github_repository.mcp_venus_os]
resource "github_repository_dependabot_security_updates" "mcp_venus_os" {
  repository = github_repository.mcp_venus_os.id
resource "github_repository" "solar_forecast_langgraph" {
  name        = "solar-forecast-langgraph"
  description = "LangGraph workflow for solar forecasting with weather data, historical generation, panel config, and inverter-control integration"
    "langgraph", "python", "solar", "forecast", "weather",
    "victron", "inverter-control"
resource "github_repository_vulnerability_alerts" "solar_forecast_langgraph" {
  repository = github_repository.solar_forecast_langgraph.name
  depends_on = [github_repository.solar_forecast_langgraph]
resource "github_repository_dependabot_security_updates" "solar_forecast_langgraph" {
  repository = github_repository.solar_forecast_langgraph.id
resource "github_repository" "mqtt_observability_opentelemetry" {
  name        = "mqtt-observability-opentelemetry"
  description = "Complete OpenTelemetry observability stack for MQTT-based IoT systems — MQTT message interception with W3C trace context propagation, Mosquitto broker metrics exporter, topic-based span processing, and Grafana/Jaeger/Prometheus visualization. Ready-to-run Docker Compose stack for Venus OS and IoT deployments."
  has_discussions = true
    "docker", "grafana", "iot", "jaeger", "mqtt", "mqtt-interceptor",
    "observability", "opentelemetry", "prometheus", "python", "tempo",
resource "github_repository_vulnerability_alerts" "mqtt_observability_opentelemetry" {
  repository = github_repository.mqtt_observability_opentelemetry.name
  depends_on = [github_repository.mqtt_observability_opentelemetry]
resource "github_repository_dependabot_security_updates" "mqtt_observability_opentelemetry" {
  repository = github_repository.mqtt_observability_opentelemetry.id
resource "github_repository" "esphome_ble_sensor_patterns" {
  name        = "esphome-ble-sensor-patterns"
  description = "Production-ready patterns for ESPHome BLE sensors — iBeacon, Eddystone, and custom BLE service parsing with lambda filters. Covers ESP32 Bluetooth proxy, passive scanning, and Home Assistant integration for battery-powered sensors."
    "ble", "bluetooth-low-energy", "bluetooth-proxy", "bms", "esp32",
    "esphome", "home-assistant", "ibeacon", "iot", "lambda",
    "passive-scanning", "plant-sensor", "reference-implementation",
    "sensor", "temperature-sensor", "venus-os", "victron", "xiaomi"
resource "github_repository_vulnerability_alerts" "esphome_ble_sensor_patterns" {
  repository = github_repository.esphome_ble_sensor_patterns.name
  depends_on = [github_repository.esphome_ble_sensor_patterns]
resource "github_repository_dependabot_security_updates" "esphome_ble_sensor_patterns" {
  repository = github_repository.esphome_ble_sensor_patterns.id
resource "github_repository" "fastapi_mqtt_gateway" {
  name        = "fastapi-mqtt-gateway"
  description = "Production-ready REST/WebSocket → MQTT bridge"
    "fastapi", "mqtt", "rest", "websocket", "gateway",
    "python", "bridge"
resource "github_repository_vulnerability_alerts" "fastapi_mqtt_gateway" {
  repository = github_repository.fastapi_mqtt_gateway.name
  depends_on = [github_repository.fastapi_mqtt_gateway]
resource "github_repository_dependabot_security_updates" "fastapi_mqtt_gateway" {
  repository = github_repository.fastapi_mqtt_gateway.id
resource "github_repository" "dbus_service_template" {
  name        = "dbus-service-template"
  description = "Production-ready Copier template for D-Bus services targeting Victron Venus OS"
    "cerbo-gx", "copier", "dbus", "template", "venus-os",
    "victron", "service-template"
resource "github_repository_vulnerability_alerts" "dbus_service_template" {
  repository = github_repository.dbus_service_template.name
  depends_on = [github_repository.dbus_service_template]
resource "github_repository_dependabot_security_updates" "dbus_service_template" {
  repository = github_repository.dbus_service_template.id
resource "github_repository" "profile_4alvit" {
  name        = "4alvit"
  description = "My GitHub profile"
  has_wiki        = false
    "profile", "github-profile"
resource "github_repository" "terraform_github_victron" {
  name        = "terraform-github-victron"
  description = "Terraform IaC for victron-venus GitHub organization infrastructure"
    "github", "hcp-terraform", "iac", "infrastructure-as-code",
    "terraform", "victron", "victron-venus"
resource "github_repository" "home_assistant" {
  name        = "home-assistant"
  description = "Home Assistant configuration"
  visibility  = "private"
    "home-assistant", "home-automation", "yaml"
resource "github_repository" "terraform_github_4alvit" {
  name        = "terraform-github-4alvit"
  description = "Terraform IaC for 4alvit personal GitHub account infrastructure"
    "terraform", "github", "iac", "infrastructure-as-code",
    "hcp-terraform", "4alvit"
resource "github_repository_vulnerability_alerts" "terraform_github_4alvit" {
  repository = github_repository.terraform_github_4alvit.name
  depends_on = [github_repository.terraform_github_4alvit]
resource "github_repository_dependabot_security_updates" "terraform_github_4alvit" {
  repository = github_repository.terraform_github_4alvit.id
# iot-project-builder-profile (transferred from victron-venus org)
resource "github_repository" "iot_project_builder_profile" {
  name        = "iot-project-builder-profile"
  description = "Automated engineering profile generator for IoT developers based on GitHub activity"
    "engineering-profile", "esp32", "esphome", "github-api", "iot",
    "llm", "profile-generator", "python"
resource "github_repository_vulnerability_alerts" "iot_project_builder_profile" {
  depends_on = [github_repository.iot_project_builder_profile]
resource "github_repository_dependabot_security_updates" "iot_project_builder_profile" {
  repository = github_repository.iot_project_builder_profile.id
# Import Blocks (for existing repos)
# Repositories
import {
  to = github_repository.energy_data_rag_pipeline
  id = "energy-data-rag-pipeline"
  to = github_repository.mcp_venus_os
  id = "mcp-venus-os"
  to = github_repository.solar_forecast_langgraph
  id = "solar-forecast-langgraph"
  to = github_repository.mqtt_observability_opentelemetry
  id = "mqtt-observability-opentelemetry"
  to = github_repository.esphome_ble_sensor_patterns
  id = "esphome-ble-sensor-patterns"
  to = github_repository.fastapi_mqtt_gateway
  id = "fastapi-mqtt-gateway"
  to = github_repository.dbus_service_template
  id = "dbus-service-template"
  to = github_repository.profile_4alvit
  id = "4alvit"
  to = github_repository.terraform_github_victron
  id = "terraform-github-victron"
  to = github_repository.home_assistant
  id = "home-assistant"
  to = github_repository.iot_project_builder_profile
  id = "iot-project-builder-profile"
# Vulnerability alerts
  to = github_repository_vulnerability_alerts.energy_data_rag_pipeline
  to = github_repository_vulnerability_alerts.mcp_venus_os
  to = github_repository_vulnerability_alerts.solar_forecast_langgraph
  to = github_repository_vulnerability_alerts.mqtt_observability_opentelemetry
  to = github_repository_vulnerability_alerts.esphome_ble_sensor_patterns
  to = github_repository_vulnerability_alerts.fastapi_mqtt_gateway
  to = github_repository_vulnerability_alerts.dbus_service_template
  to = github_repository_vulnerability_alerts.iot_project_builder_profile
# Dependabot security updates
  to = github_repository_dependabot_security_updates.energy_data_rag_pipeline
  to = github_repository_dependabot_security_updates.mcp_venus_os
  to = github_repository_dependabot_security_updates.solar_forecast_langgraph
  to = github_repository_dependabot_security_updates.mqtt_observability_opentelemetry
  to = github_repository_dependabot_security_updates.esphome_ble_sensor_patterns
  to = github_repository_dependabot_security_updates.fastapi_mqtt_gateway
  to = github_repository_dependabot_security_updates.dbus_service_template
  to = github_repository_dependabot_security_updates.iot_project_builder_profile
# Branch Protection Rulesets
data "github_app" "gitar" {
  slug = "gitar-bot"
locals {
  protected_repos = [
    "energy-data-rag-pipeline",
    "mcp-venus-os",
    "solar-forecast-langgraph",
    "mqtt-observability-opentelemetry",
    "esphome-ble-sensor-patterns",
    "fastapi-mqtt-gateway",
    "dbus-service-template",
    "terraform-github-victron",
    "4alvit",
    "terraform-github-4alvit",
resource "github_repository_ruleset" "default" {
  for_each    = toset(local.protected_repos)
  name        = "Default"
  repository  = each.value
  target      = "branch"
  enforcement = "active"
  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
    actor_id    = data.github_app.gitar.id
    actor_type  = "Integration"
  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
  rules {
    deletion            = true
    non_fast_forward    = true
    required_signatures = true
    copilot_code_review {
      review_draft_pull_requests = true
      review_on_push             = true
    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    required_code_scanning {
      required_code_scanning_tool {
        alerts_threshold          = "errors"
        security_alerts_threshold = "high_or_higher"
        tool                      = "CodeQL"
      }
