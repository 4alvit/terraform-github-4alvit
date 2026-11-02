# Room already has immutable version tags in ios-products.tf. Do not opt it into
# release_channel_repositories and create a second owner for release resources.
# This narrow rollout adds only its environment, branch policy and publication flag.
variable "room_release_channels_enabled" {
  description = "Enable Room GitHub candidate publication only after reviewed main CI and deployment-hook checks"
  type        = bool
  default     = false
}

data "github_repository" "room_release" {
  full_name = "${var.github_organization}/room-inventory-ios"

  lifecycle {
    postcondition {
      condition = (
        self.full_name == "4alvit/room-inventory-ios" &&
        self.repo_id == 1432741511 &&
        self.visibility == "public" && !self.archived && self.default_branch == "main"
      )
      error_message = "Room release activation requires repository ID 1432741511: public, active 4alvit/room-inventory-ios with default branch main."
    }
  }
}

data "github_user" "room_release_reviewer" {
  username = "californiantiramisu"

  lifecycle {
    postcondition {
      condition     = self.id == "319626568"
      error_message = "The Room release reviewer must match the previously verified GitHub user identity."
    }
  }
}

resource "github_repository_environment" "room_release" {
  repository  = data.github_repository.room_release.name
  environment = "release"

  # Retain the shared single-maintainer release policy and owner emergency bypass.
  # A required approval is configured; this is not a two-person review guarantee.
  prevent_self_review = false
  can_admins_bypass   = true
  reviewers {
    users = [tonumber(data.github_user.room_release_reviewer.id)]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "room_release" {
  repository     = data.github_repository.room_release.name
  environment    = github_repository_environment.room_release.environment
  branch_pattern = data.github_repository.room_release.default_branch
}

resource "github_actions_variable" "room_release_channels_enabled" {
  repository    = data.github_repository.room_release.name
  variable_name = "RELEASE_CHANNELS_ENABLED"
  value         = var.room_release_channels_enabled ? "true" : "false"

  # Candidate jobs have no environment approval. Initial provisioning stays
  # disabled; activation requires a separate reviewed plan after live verification.
  depends_on = [github_repository_environment_deployment_policy.room_release]
}
