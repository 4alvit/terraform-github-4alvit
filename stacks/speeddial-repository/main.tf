terraform {
  required_version = ">= 1.15.7"

  cloud {
    organization = "victron-venus"
    workspaces {
      name = "github-speeddial-repository"
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

resource "github_repository" "speeddial" {
  name                   = "speeddial"
  description            = "Self-hosted Speed Dial with editable screenshot tiles, persistent settings, and Kubernetes deployment"
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
  topics                 = ["bookmarks", "k3s", "nodejs", "self-hosted", "speeddial"]

  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = data.github_user.authenticated.login == "4alvit"
      error_message = "Repository creation requires the authenticated GitHub user 4alvit."
    }
  }
}

resource "github_repository_vulnerability_alerts" "speeddial" {
  repository = github_repository.speeddial.name
}

resource "github_repository_dependabot_security_updates" "speeddial" {
  repository = github_repository.speeddial.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.speeddial]
}

output "repository_url" {
  value = github_repository.speeddial.html_url
}
