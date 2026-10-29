# Adopt only the existing branch ruleset; repository and release ownership stay
# with their current configuration. The source policy was verified on 2026-10-29.
data "github_repository" "speeddial" {
  full_name = "4alvit/speeddial"
}

resource "github_repository_ruleset" "speeddial_main" {
  name        = "Public main review and CI"
  repository  = data.github_repository.speeddial.name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = local.owner_emergency_merge_actor.actor_id
    actor_type  = local.owner_emergency_merge_actor.actor_type
    bypass_mode = local.owner_emergency_merge_actor.bypass_mode
  }

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = false
      required_check {
        context = "Application checks"
        # The existing check accepts any source; do not pin an integration.
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    precondition {
      condition = (
        var.github_organization == "4alvit" &&
        data.github_repository.speeddial.name == "speeddial" &&
        data.github_repository.speeddial.visibility == "public" &&
        !data.github_repository.speeddial.archived
      )
      error_message = "Speed Dial governance requires the active public 4alvit/speeddial repository."
    }
  }
}
