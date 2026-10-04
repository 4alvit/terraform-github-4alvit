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

resource "github_repository_dependabot_security_updates" "ruview" {
  repository = github_repository.ruview.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.ruview]
}

output "repository_url" {
  value = github_repository.ruview.html_url
}
