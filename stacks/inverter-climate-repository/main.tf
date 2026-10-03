terraform {
  required_version = ">= 1.15.7"

  cloud {
    organization = "victron-venus"
    workspaces {
      name = "github-inverter-climate-repository"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Authentication comes from the existing GITHUB_TOKEN process environment.
# Clear GITHUB_OWNER and GITHUB_ORGANIZATION before running the provider.
provider "github" {
  owner = "victron-venus"
}

data "github_user" "authenticated" {
  username = ""
}

resource "github_repository" "climate" {
  name                   = "inverter-climate"
  description            = "Energy-aware climate coordination via Home Assistant and Victron"
  visibility             = "public"
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
  license_template       = "mit"
  topics = [
    "climate", "energy-management", "home-assistant", "nest", "python",
    "solar", "thermostat", "venus-os", "victron",
  ]

  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = data.github_user.authenticated.login == "4alvit"
      error_message = "Repository creation requires the authenticated GitHub user 4alvit."
    }
  }
}

resource "github_repository_vulnerability_alerts" "climate" {
  repository = github_repository.climate.name
}

resource "github_repository_dependabot_security_updates" "climate" {
  repository = github_repository.climate.id
  enabled    = true

  depends_on = [github_repository_vulnerability_alerts.climate]
}

resource "github_workflow_repository_permissions" "climate" {
  repository                       = github_repository.climate.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

# Required CI checks can be enabled after application workflows exist and pass.
resource "github_repository_ruleset" "climate" {
  name        = "Protect main"
  repository  = github_repository.climate.name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
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
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      required_approving_review_count   = 0
      required_review_thread_resolution = true
    }
  }
}

output "repository_url" {
  value = github_repository.climate.html_url
}
