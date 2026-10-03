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
  enabled    = false

  depends_on = [github_repository_vulnerability_alerts.climate]
}

resource "github_workflow_repository_permissions" "climate" {
  repository                       = github_repository.climate.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

# The shared Quality gate workflow must be merged and green before applying.
resource "github_repository_ruleset" "climate" {
  name        = "Protect main"
  repository  = github_repository.climate.name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
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
    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = false
      required_check {
        context        = "CI gate"
        integration_id = 15368
      }
    }
    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      required_approving_review_count   = 0
      required_review_thread_resolution = true
    }
  }
}

resource "github_repository_ruleset" "immutable_release_tags" {
  name        = "Release standard - immutable version tags"
  repository  = github_repository.climate.name
  target      = "tag"
  enforcement = "active"
  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }
  rules {
    deletion         = true
    update           = true
    non_fast_forward = true
  }
}

resource "github_repository_environment" "release" {
  repository          = github_repository.climate.name
  environment         = "release"
  prevent_self_review = false
  can_admins_bypass   = true
  reviewers {
    users = [tonumber(data.github_user.authenticated.id)]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "release" {
  repository     = github_repository.climate.name
  environment    = github_repository_environment.release.environment
  branch_pattern = "main"
}

resource "github_actions_variable" "release_publication" {
  repository    = github_repository.climate.name
  variable_name = "RELEASE_CHANNELS_ENABLED"
  value         = "true"
  depends_on = [
    github_repository_ruleset.climate,
    github_repository_ruleset.immutable_release_tags,
    github_repository_environment.release,
    github_repository_environment_deployment_policy.release,
  ]
}

resource "github_actions_variable" "setuphelper_publication" {
  repository    = github_repository.climate.name
  variable_name = "SETUPHELPER_PUBLICATION_ENABLED"
  value         = "true"
  depends_on    = [github_actions_variable.release_publication]
}

output "repository_url" {
  value = github_repository.climate.html_url
}
