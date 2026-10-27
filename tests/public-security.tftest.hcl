mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "review_requires_one_current_approval_with_owner_exception" {
  command = plan
  variables {
    public_security_enforcement_repositories = ["amazon-echo-home-voice", "google-home-voice-stats"]
  }
  assert {
    condition     = length(github_repository_ruleset.public_review) == 2
    error_message = "Explicitly selected public repositories must receive review rules."
  }
  assert {
    condition = alltrue([
      for policy in github_repository_ruleset.public_review : (
        (
          length([for actor in policy.bypass_actors : actor if actor.actor_type == local.owner_emergency_merge_actor.actor_type]) == 1 &&
          alltrue([
            for actor in policy.bypass_actors :
            coalesce(actor.actor_id, 0) == coalesce(local.owner_emergency_merge_actor.actor_id, 0) && actor.bypass_mode == "pull_request"
            if actor.actor_type == local.owner_emergency_merge_actor.actor_type
          ]) &&
          length([for actor in policy.bypass_actors : actor if actor.actor_type != local.owner_emergency_merge_actor.actor_type]) == 0
        ) &&
        one(one(policy.rules).pull_request).required_approving_review_count == 1 &&
        one(one(policy.rules).pull_request).dismiss_stale_reviews_on_push &&
        one(one(policy.rules).pull_request).require_last_push_approval &&
        one(one(policy.rules).pull_request).required_review_thread_resolution
      )
    ])
    error_message = "New public review rules must have only the owner emergency exception and require current reviews."
  }
}

run "retired_hacs_fork_is_not_reactivated_by_stale_selection" {
  command = plan
  variables {
    public_security_enforcement_repositories = ["default", "amazon-echo-home-voice"]
  }
  assert {
    condition = (
      !contains(keys(data.github_repository.public_software), "default") &&
      !contains(keys(github_repository_ruleset.public_review), "default") &&
      !contains(keys(github_repository_collaborator.automation_bot), "default")
    )
    error_message = "The retired HACS submission fork must not be queried or regain review automation or bot access."
  }
  assert {
    condition = (
      contains(keys(github_repository_ruleset.public_review), "amazon-echo-home-voice") &&
      github_repository_collaborator.automation_bot["cisco-home-telephony"].permission == "push" &&
      github_repository_collaborator.automation_bot["terraform-github-ha-homelab"].permission == "push"
    )
    error_message = "Retiring the HACS fork must preserve selected protections and existing automation access for active repositories."
  }
}

run "private_repository_is_excluded" {
  command = plan
  variables {
    public_security_enforcement_repositories = ["amazon-echo-home-voice"]
  }
  override_data {
    target = data.github_repository.public_software["amazon-echo-home-voice"]
    values = {
      visibility = "private"
      archived   = false
    }
  }
  assert {
    condition     = !contains(local.active_public_software_repositories, "amazon-echo-home-voice") && !contains(keys(github_repository_ruleset.public_review), "amazon-echo-home-voice")
    error_message = "Do not apply public security rules to private repositories."
  }
}

run "archived_repository_is_excluded" {
  command = plan
  variables {
    public_security_enforcement_repositories = ["amazon-echo-home-voice"]
  }
  override_data {
    target = data.github_repository.public_software["amazon-echo-home-voice"]
    values = {
      visibility = "public"
      archived   = true
    }
  }
  assert {
    condition     = !contains(local.active_public_software_repositories, "amazon-echo-home-voice") && !contains(keys(github_repository_ruleset.public_review), "amazon-echo-home-voice")
    error_message = "Do not change archived repository protections."
  }
}

run "reconciliation_preserves_existing_governance" {
  command = plan
  assert {
    condition     = length(github_repository_ruleset.public_review) == 0
    error_message = "Routine reconciliation must not activate unreviewed review rules."
  }
}

run "emergency_merge_is_limited_to_the_owner_and_pull_requests" {
  command = plan
  assert {
    condition = (
      local.owner_emergency_merge_actor.actor_type == "User" &&
      local.owner_emergency_merge_actor.actor_id == 272257197 &&
      local.owner_emergency_merge_actor.bypass_mode == "pull_request"
    )
    error_message = "Only the declared owner may use the emergency PR exception; repository roles, automation and direct pushes are not added."
  }
}
