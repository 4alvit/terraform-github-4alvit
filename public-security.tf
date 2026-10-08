# Public software explicitly audited for the OpenSSF rollout. Private and archived
# repositories are excluded using live visibility before new rules are created.
locals {
  public_software_repositories = toset([
    "amazon-echo-home-voice",
    "dbus-service-template",
    "default",
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
    "default",
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
}

resource "github_repository_ruleset" "public_review" {
  for_each = toset([
    for repo in local.public_missing_review_repositories : repo
    if data.github_repository.public_software[repo].visibility == "public" && !data.github_repository.public_software[repo].archived
  ])
  name        = "Public software - required review"
  repository  = each.value
  target      = "branch"
  enforcement = "active"
  # Intentionally no bypass actors, including administrators and automation apps.
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
      required_approving_review_count   = 2
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
  }
}
