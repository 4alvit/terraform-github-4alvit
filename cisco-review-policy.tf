# This application predates its canonical governance registration. Manage only
# its new protection here; the existing repository is not created or imported.
data "github_repository" "cisco_home_telephony" {
  full_name = "4alvit/cisco-home-telephony"
}

resource "github_repository_ruleset" "cisco_main" {
  depends_on = [github_repository_collaborator.automation_bot["cisco-home-telephony"]]

  name        = "Cisco required CI and review"
  repository  = data.github_repository.cisco_home_telephony.name
  target      = "branch"
  enforcement = "active"
  # No administrator or automation bypass: --auto must wait for actual checks.
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
    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = false
      required_check {
        context        = "validate"
        integration_id = 15368
      }
      required_check {
        context        = "Wake gate"
        integration_id = 15368
      }
    }
  }
  lifecycle {
    precondition {
      condition = (
        var.github_organization == "4alvit" &&
        data.github_repository.cisco_home_telephony.visibility == "public" &&
        !data.github_repository.cisco_home_telephony.archived
      )
      error_message = "Cisco governance requires the 4alvit owner and its active public repository."
    }
  }
}
