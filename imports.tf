# Adopt existing long-lived repositories into their canonical owner workspace.
# These blocks are idempotent after import and do not recreate repositories.
import {
  to = module.repos["terraform_github_open_ott_play"].github_repository.this
  id = "terraform-github-open-ott-play"
}

import {
  to = module.repos["home_assistant"].github_repository.this
  id = "home-assistant"
}

# Existing active write grants: import membership instead of issuing invitations.
import {
  to = github_repository_collaborator.automation_bot["4alvit"]
  id = "4alvit:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["amazon-echo-home-voice"]
  id = "amazon-echo-home-voice:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["dbus-service-template"]
  id = "dbus-service-template:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["demo"]
  id = "demo:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["energy-data-rag-pipeline"]
  id = "energy-data-rag-pipeline:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["esphome-ble-sensor-patterns"]
  id = "esphome-ble-sensor-patterns:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["fastapi-mqtt-gateway"]
  id = "fastapi-mqtt-gateway:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["github-deploy-webhook"]
  id = "github-deploy-webhook:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["google-home-voice-stats"]
  id = "google-home-voice-stats:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["home-assistant-k3s"]
  id = "home-assistant-k3s:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["iot-project-builder-profile"]
  id = "iot-project-builder-profile:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["k3s-self-healing"]
  id = "k3s-self-healing:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["mcp-venus-os"]
  id = "mcp-venus-os:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["mqtt-observability-opentelemetry"]
  id = "mqtt-observability-opentelemetry:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["solar-forecast-langgraph"]
  id = "solar-forecast-langgraph:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-cloudflare-alvit"]
  id = "terraform-cloudflare-alvit:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-github-4alvit"]
  id = "terraform-github-4alvit:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-github-open-ott-play"]
  id = "terraform-github-open-ott-play:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-github-victron"]
  id = "terraform-github-victron:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-oracle-oci"]
  id = "terraform-oracle-oci:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-portainer-synology"]
  id = "terraform-portainer-synology:californiantiramisu"
}

import {
  to = github_repository_collaborator.automation_bot["terraform-synology-alvit"]
  id = "terraform-synology-alvit:californiantiramisu"
}

import {
  to = github_repository_ruleset.default["iot-project-builder-profile"]
  id = "iot-project-builder-profile:20201721"
}

import {
  to = github_repository_ruleset.default["terraform-github-open-ott-play"]
  id = "terraform-github-open-ott-play:21269604"
}
