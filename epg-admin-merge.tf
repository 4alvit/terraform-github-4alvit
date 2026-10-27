# The existing EPG classic rule was outside Terraform. Adopt it into this state
# before the two-phase ruleset migration; see docs/EPG_BRANCH_PROTECTION.md.
data "github_repository" "epg_voice_gateway" {
  full_name = "4alvit/epg-voice-gateway"
}

resource "github_repository_ruleset" "epg_main" {
  name        = "EPG main review and CI"
  repository  = data.github_repository.epg_voice_gateway.name
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
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = false
      required_check {
        context        = "python"
        integration_id = 15368
      }
    }
  }

  lifecycle {
    precondition {
      condition = (
        var.github_organization == "4alvit" &&
        data.github_repository.epg_voice_gateway.visibility == "public" &&
        !data.github_repository.epg_voice_gateway.archived
      )
      error_message = "EPG governance requires the 4alvit owner and its active public repository."
    }
  }
}
