terraform {
  required_version = ">= 1.15.7"

  cloud {
    organization = "victron-venus"

    workspaces {
      name = "github-4alvit-infrastructure"
    }
  }
}

provider "github" {
  owner = var.github_organization
  token = var.github_token
}

# =============================================================================
# Relocate existing flat resources into module.repos.
# The github provider does not support `moved {}` across resource types, so
# re-associate state manually with `terraform state mv`:
# =============================================================================
# Repository definitions
# =============================================================================

locals {
  repositories = {
    energy_data_rag_pipeline = {
      name        = "energy-data-rag-pipeline"
      description = "RAG pipeline for Victron Energy documentation with pgvector, LangChain, and FastAPI"
      visibility  = "public"
      topics = [
        "fastapi", "langchain", "pgvector", "python", "rag",
        "victron", "energy", "documentation"
      ]
    },

    mcp_venus_os = {
      name        = "mcp-venus-os"
      description = "MCP server for Venus OS management - D-Bus, MQTT, and safety-constrained control"
      visibility  = "public"
      topics = [
        "cerbo-gx", "dbus", "mcp", "mqtt", "python",
        "venus-os", "victron"
      ]
    },

    solar_forecast_langgraph = {
      name        = "solar-forecast-langgraph"
      description = "LangGraph workflow for solar forecasting with weather data, historical generation, panel config, and inverter-control integration"
      visibility  = "public"
      topics = [
        "langgraph", "python", "solar", "forecast", "weather",
        "victron", "inverter-control"
      ]
    },

    mqtt_observability_opentelemetry = {
      name        = "mqtt-observability-opentelemetry"
      description = "Complete OpenTelemetry observability stack for MQTT-based IoT systems — MQTT message interception with W3C trace context propagation, Mosquitto broker metrics exporter, topic-based span processing, and Grafana/Jaeger/Prometheus visualization. Ready-to-run Docker Compose stack for Venus OS and IoT deployments."
      visibility  = "public"
      topics = [
        "docker", "grafana", "iot", "jaeger", "mqtt", "mqtt-interceptor",
        "observability", "opentelemetry", "prometheus", "python", "tempo",
        "venus-os", "victron"
      ]
    },

    esphome_ble_sensor_patterns = {
      name        = "esphome-ble-sensor-patterns"
      description = "Production-ready patterns for ESPHome BLE sensors — iBeacon, Eddystone, and custom BLE service parsing with lambda filters. Covers ESP32 Bluetooth proxy, passive scanning, and Home Assistant integration for battery-powered sensors."
      visibility  = "public"
      topics = [
        "ble", "bluetooth-low-energy", "bluetooth-proxy", "bms", "esp32",
        "esphome", "home-assistant", "ibeacon", "iot", "lambda",
        "passive-scanning", "plant-sensor", "reference-implementation",
        "sensor", "temperature-sensor", "venus-os", "victron", "xiaomi"
      ]
    },

    fastapi_mqtt_gateway = {
      name        = "fastapi-mqtt-gateway"
      description = "Production-ready REST/WebSocket → MQTT bridge"
      visibility  = "public"
      topics = [
        "fastapi", "mqtt", "rest", "websocket", "gateway",
        "python", "bridge"
      ]
    },

    dbus_service_template = {
      name        = "dbus-service-template"
      description = "Production-ready Copier template for D-Bus services targeting Victron Venus OS"
      visibility  = "public"
      topics = [
        "cerbo-gx", "copier", "dbus", "template", "venus-os",
        "victron", "service-template"
      ]
    },

    profile_4alvit = {
      name        = "4alvit"
      description = "My GitHub profile"
      visibility  = "public"
      has_wiki    = false
      topics = [
        "profile", "github-profile"
      ]
    },

    terraform_github_victron = {
      name        = "terraform-github-victron"
      description = "Terraform IaC for victron-venus GitHub organization infrastructure"
      visibility  = "public"
      topics = [
        "github", "hcp-terraform", "iac", "infrastructure-as-code",
        "terraform", "victron", "victron-venus"
      ]
    },

    demo = {
      name             = "demo"
      description      = "Private Graphify indexing sandbox"
      visibility       = "private"
      has_wiki         = false
      license_template = ""
      topics           = ["graphify"]
    },

    terraform_github_4alvit = {
      name        = "terraform-github-4alvit"
      description = "Terraform IaC for 4alvit personal GitHub account infrastructure"
      visibility  = "public"
      topics = [
        "terraform", "github", "iac", "infrastructure-as-code",
        "hcp-terraform", "4alvit"
      ]
    },

    iot_project_builder_profile = {
      name        = "iot-project-builder-profile"
      description = "Automated engineering profile generator for IoT developers based on GitHub activity"
      visibility  = "public"
      topics = [
        "engineering-profile", "esp32", "esphome", "github-api", "iot",
        "llm", "profile-generator", "python"
      ]
    },
  }
}

module "repos" {
  source   = "./modules/github_repo"
  for_each = local.repositories

  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility

  has_issues      = try(each.value.has_issues, true)
  has_projects    = try(each.value.has_projects, true)
  has_wiki        = try(each.value.has_wiki, true)
  has_discussions = try(each.value.has_discussions, false)

  topics           = each.value.topics
  license_template = try(each.value.license_template, "mit")
}

# =============================================================================
# Root-level resources (not per-repo)
# =============================================================================

# Vulnerability alerts + Dependabot security updates are kept at the root
# with the same flat addresses they had before. The integrations/github
# provider does not support `moved {}` for these resource types when the
# target lives inside a module instance, so we keep the addresses
# unchanged and only swap the `repository` attribute source to the
# module output. This keeps `terraform plan` move-only for these
# resources too.

resource "github_repository_vulnerability_alerts" "energy_data_rag_pipeline" {
  repository = module.repos["energy_data_rag_pipeline"].repository.name
}

resource "github_repository_vulnerability_alerts" "mcp_venus_os" {
  repository = module.repos["mcp_venus_os"].repository.name
}

resource "github_repository_vulnerability_alerts" "solar_forecast_langgraph" {
  repository = module.repos["solar_forecast_langgraph"].repository.name
}

resource "github_repository_vulnerability_alerts" "mqtt_observability_opentelemetry" {
  repository = module.repos["mqtt_observability_opentelemetry"].repository.name
}

resource "github_repository_vulnerability_alerts" "esphome_ble_sensor_patterns" {
  repository = module.repos["esphome_ble_sensor_patterns"].repository.name
}

resource "github_repository_vulnerability_alerts" "fastapi_mqtt_gateway" {
  repository = module.repos["fastapi_mqtt_gateway"].repository.name
}

resource "github_repository_vulnerability_alerts" "dbus_service_template" {
  repository = module.repos["dbus_service_template"].repository.name
}

resource "github_repository_vulnerability_alerts" "terraform_github_4alvit" {
  repository = module.repos["terraform_github_4alvit"].repository.name
}

resource "github_repository_vulnerability_alerts" "iot_project_builder_profile" {
  repository = module.repos["iot_project_builder_profile"].repository.name
}

resource "github_repository_dependabot_security_updates" "energy_data_rag_pipeline" {
  repository = module.repos["energy_data_rag_pipeline"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "mcp_venus_os" {
  repository = module.repos["mcp_venus_os"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "solar_forecast_langgraph" {
  repository = module.repos["solar_forecast_langgraph"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "mqtt_observability_opentelemetry" {
  repository = module.repos["mqtt_observability_opentelemetry"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "esphome_ble_sensor_patterns" {
  repository = module.repos["esphome_ble_sensor_patterns"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "fastapi_mqtt_gateway" {
  repository = module.repos["fastapi_mqtt_gateway"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "dbus_service_template" {
  repository = module.repos["dbus_service_template"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "terraform_github_4alvit" {
  repository = module.repos["terraform_github_4alvit"].repository.id
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "iot_project_builder_profile" {
  repository = module.repos["iot_project_builder_profile"].repository.id
  enabled    = true
}

resource "github_repository_pages" "iot_project_builder_profile" {
  repository = module.repos["iot_project_builder_profile"].repository.name
  source {
    branch = "main"
    path   = "/docs"
  }
}

data "github_app" "gitar" {
  slug = "gitar-bot"
}

locals {
  protected_repo_names = [
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
  ]
}

resource "github_repository_ruleset" "default" {
  for_each    = toset(local.protected_repo_names)
  name        = "Default"
  repository  = each.value
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = data.github_app.gitar.id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion            = true
    non_fast_forward    = true
    required_signatures = true

    copilot_code_review {
      review_draft_pull_requests = true
      review_on_push             = true
    }

    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }

    required_code_scanning {
      required_code_scanning_tool {
        alerts_threshold          = "errors"
        security_alerts_threshold = "high_or_higher"
        tool                      = "CodeQL"
      }
    }
  }
}
