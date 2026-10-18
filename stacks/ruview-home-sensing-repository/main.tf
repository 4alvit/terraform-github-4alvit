terraform {
  required_version = ">= 1.15.7"

  cloud {
    organization = "victron-venus"
    workspaces {
      name = "github-ruview-home-sensing-repository"
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
  owner = "4alvit"
  # Provider 6.x checks organization before GITHUB_OWNER or the owner attribute.
  # Pin both to prevent inherited environment variables redirecting this stack.
  organization = "4alvit"
}

data "github_user" "authenticated" {
  username = ""
}

resource "github_repository" "ruview" {
  name                   = "ruview-home-sensing"
  description            = "Private RuView Wi-Fi sensing, k3s deployment, and Home Assistant 3D floorplan integration"
  visibility             = "private"
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = false
  delete_branch_on_merge = true
  archive_on_destroy     = true
  topics                 = ["esp32", "home-assistant", "k3s", "ruview", "terraform", "wifi-sensing"]

  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = data.github_user.authenticated.login == "4alvit"
      error_message = "Repository creation requires the authenticated GitHub user 4alvit."
    }
  }
}

resource "github_repository_vulnerability_alerts" "ruview" {
  repository = github_repository.ruview.name
}

# Permit the shared reviewer fallback for bot-authored pull requests without
# giving ordinary workflow tokens write access to repository contents.
resource "github_workflow_repository_permissions" "ruview" {
  repository                       = github_repository.ruview.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

resource "github_repository_dependabot_security_updates" "ruview" {
  repository = github_repository.ruview.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.ruview]
}

# Keep routing in the same state as the repository. Each scale set executes one
# job per disposable pod; CI and metadata have separate runner identities.
variable "ci_runner_mode" {
  type        = string
  default     = "self-hosted"
  description = "RuView CI runner profile; github restores GitHub-hosted compute."

  validation {
    condition     = contains(["github", "self-hosted", "k3s"], var.ci_runner_mode)
    error_message = "Use github, self-hosted, or the compatible k3s alias."
  }
}

locals {
  # Matches the private ARC fleet renderer; no registration data is stored here.
  runner_pool_prefix = "private-${substr(sha256("4alvit/ruview-home-sensing"), 0, 12)}"
}

resource "github_actions_variable" "runner" {
  for_each = {
    CI_RUNNER_MODE              = var.ci_runner_mode
    CI_RUNNER_LABELS            = jsonencode(["${local.runner_pool_prefix}-ci"])
    CI_RUNNER_ARM64_LABELS      = jsonencode(["${local.runner_pool_prefix}-arm64"])
    CI_RUNNER_AUTOMATION_LABELS = jsonencode(["${local.runner_pool_prefix}-automation"])
  }
  repository    = github_repository.ruview.name
  variable_name = each.key
  value         = each.value
}

output "repository_url" {
  value = github_repository.ruview.html_url
}
