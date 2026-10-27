# Public software explicitly audited for the OpenSSF rollout. Private and archived
# repositories are excluded using live visibility before new rules are created.
variable "public_security_enforcement_repositories" {
  description = "Public repositories explicitly approved for new review rules and removal of legacy bypasses; owner emergency merges remain available after reviewer readiness is verified"
  type        = set(string)
  default     = []
}

locals {
  public_software_repositories = toset([
    "amazon-echo-home-voice",
    "dbus-service-template",
    "energy-data-rag-pipeline",
    "esphome-ble-sensor-patterns",
    "fastapi-mqtt-gateway",
    "google-home-voice-stats",
    "iot-project-builder-profile",
    "mcp-venus-os",
    "mqtt-observability-opentelemetry",
    "solar-forecast-langgraph",
    "terraform-github-4alvit",
    "terraform-github-ha-homelab",
    "terraform-github-open-ott-play",
    "terraform-github-victron"
  ])
  public_missing_review_repositories = toset([
    "amazon-echo-home-voice",
    "google-home-voice-stats"
  ])
}

data "github_repository" "public_software" {
  for_each  = local.public_software_repositories
  full_name = "${var.github_organization}/${each.value}"
}

locals {
  active_public_software_repositories = toset([
    for repo, metadata in data.github_repository.public_software : repo
    if metadata.visibility == "public" && !metadata.archived
  ])
  enforced_public_software_repositories = setintersection(
    local.active_public_software_repositories,
    var.public_security_enforcement_repositories
  )
}

resource "github_repository_ruleset" "public_review" {
  for_each = toset([
    for repo in local.public_missing_review_repositories : repo
    if contains(local.enforced_public_software_repositories, repo)
  ])
  name        = "Public software - required review"
  repository  = each.value
  target      = "branch"
  enforcement = "active"
  # The emergency owner exception below does not grant automation a bypass.
  # Owners may make an explicit emergency merge through an auditable PR.
  bypass_actors {
    actor_id    = local.owner_emergency_merge_actor.actor_id
    actor_type  = local.owner_emergency_merge_actor.actor_type
    bypass_mode = local.owner_emergency_merge_actor.bypass_mode
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }
  rules {
    deletion         = true
    non_fast_forward = true
    pull_request {
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
  }
}
