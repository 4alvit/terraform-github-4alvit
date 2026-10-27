mock_provider "github" {
  override_during = plan
}

run "bootstrap_scope_and_protections" {
  command = plan

  assert {
    condition = toset(keys(module.ios_products)) == toset([
      "room-inventory-ios", "document-sanitizer-ios", "travel-documents-ios"
    ])
    error_message = "Bootstrap must own exactly the three requested iOS repositories."
  }
  assert {
    condition = alltrue([
      for branch in github_branch_default.ios_products : branch.branch == "main" && branch.rename
    ])
    error_message = "Every seed must be normalized to main before branch protections."
  }
  assert {
    condition = alltrue([
      for policy in github_repository_ruleset.ios_products_default : (
        policy.enforcement == "active" &&
        (
          length([for actor in policy.bypass_actors : actor if actor.actor_type == local.owner_emergency_merge_actor.actor_type]) == 1 &&
          alltrue([
            for actor in policy.bypass_actors :
            coalesce(actor.actor_id, 0) == coalesce(local.owner_emergency_merge_actor.actor_id, 0) && actor.bypass_mode == "pull_request"
            if actor.actor_type == local.owner_emergency_merge_actor.actor_type
          ]) &&
          length([for actor in policy.bypass_actors : actor if actor.actor_type != local.owner_emergency_merge_actor.actor_type]) == 0
        ) &&
        one(policy.rules).deletion &&
        one(policy.rules).non_fast_forward &&
        one(policy.rules).required_signatures &&
        one(one(policy.rules).pull_request).required_approving_review_count == 1 &&
        one(one(policy.rules).pull_request).dismiss_stale_reviews_on_push &&
        one(one(policy.rules).pull_request).require_last_push_approval &&
        one(one(policy.rules).pull_request).required_review_thread_resolution &&
        length(one(policy.rules).required_status_checks) == 0 &&
        length(one(policy.rules).required_code_scanning) == 0
      )
    ])
    error_message = "Bootstrap needs current reviews and signatures with only the documented owner exception or missing workflow gates."
  }
  assert {
    condition = alltrue([
      for policy in github_repository_ruleset.ios_products_version_tags : (
        policy.enforcement == "active" &&
        policy.target == "tag" &&
        length(policy.bypass_actors) == 0 &&
        one(policy.rules).deletion &&
        one(policy.rules).update &&
        one(policy.rules).non_fast_forward
      )
    ])
    error_message = "Version tags, including prereleases, must remain immutable."
  }
  assert {
    condition = alltrue([
      for permission in github_workflow_repository_permissions.ios_products : (
        permission.default_workflow_permissions == "read" && permission.can_approve_pull_request_reviews
      )
    ])
    error_message = "Default workflow tokens must be read-only while allowing explicit approval jobs."
  }
  assert {
    condition = length(github_repository_vulnerability_alerts.ios_products) == 3 && alltrue([
      for update in github_repository_dependabot_security_updates.ios_products : update.enabled
    ])
    error_message = "Every new repository must have vulnerability alerts and security updates."
  }
  assert {
    condition = alltrue([
      for reviewer in github_repository_collaborator.ios_products_automation : (
        reviewer.username == "californiantiramisu" && reviewer.permission == "push"
      )
    ])
    error_message = "Use the existing approved reviewer without administrative access."
  }
}
