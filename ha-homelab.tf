# The GitHub organization and its repositories are owned by the separate
# github-ha-homelab-infrastructure workspace. This account owns only its public
# Terraform source repository. Bootstrap created the empty repo before import.
import {
  to = module.repos["terraform_github_ha_homelab"].github_repository.this
  id = "terraform-github-ha-homelab"
}

resource "github_repository_vulnerability_alerts" "ha_homelab_infrastructure" {
  repository = module.repos["terraform_github_ha_homelab"].repository.name
}

resource "github_repository_dependabot_security_updates" "ha_homelab_infrastructure" {
  repository = module.repos["terraform_github_ha_homelab"].repository.id
  enabled    = true
}

resource "github_repository_ruleset" "ha_homelab_infrastructure" {
  name        = "Protect main"
  repository  = module.repos["terraform_github_ha_homelab"].repository.name
  target      = "branch"
  enforcement = "active"

  dynamic "bypass_actors" {
    for_each = contains(local.enforced_public_software_repositories, "terraform-github-ha-homelab") ? [] : [true]
    content {
      actor_id    = 5
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    }
  }

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
      dismiss_stale_reviews_on_push     = contains(local.enforced_public_software_repositories, "terraform-github-ha-homelab")
      require_last_push_approval        = contains(local.enforced_public_software_repositories, "terraform-github-ha-homelab")
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      required_approving_review_count   = contains(local.enforced_public_software_repositories, "terraform-github-ha-homelab") ? 1 : 0
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context = "Terraform validation"
      }
    }
  }
}
