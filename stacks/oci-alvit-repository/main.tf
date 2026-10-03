terraform {
  required_version = ">= 1.15.7"

  cloud {
    organization = "victron-venus"
    workspaces {
      name = "github-oci-alvit-repository"
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
}

data "github_user" "authenticated" {
  username = ""
}

resource "github_repository" "alvit" {
  name                   = "terraform-oracle-oci-alvit"
  description            = "Terraform for OCI Alvit Always Free infrastructure, site-to-site VPN, and k3s nodes"
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
  topics                 = ["iac", "k3s", "networking", "oci", "oracle-cloud", "terraform"]

  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = data.github_user.authenticated.login == "4alvit"
      error_message = "Repository creation requires the authenticated GitHub user 4alvit."
    }
  }
}

resource "github_repository_vulnerability_alerts" "alvit" {
  repository = github_repository.alvit.name
}

resource "github_repository_dependabot_security_updates" "alvit" {
  repository = github_repository.alvit.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.alvit]
}

output "repository_url" {
  value = github_repository.alvit.html_url
}
