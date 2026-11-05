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
      for name, policy in github_repository_ruleset.ios_products_default : (
        policy.enforcement == "active" &&
        (
          length([for actor in policy.bypass_actors : actor if actor.actor_type == local.owner_emergency_merge_actor.actor_type]) == 1 &&
          alltrue([
            for actor in policy.bypass_actors :
            coalesce(actor.actor_id, 0) == coalesce(local.owner_emergency_merge_actor.actor_id, 0) && actor.bypass_mode == "always"
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
        length(one(policy.rules).required_status_checks) == (contains(["document-sanitizer-ios", "travel-documents-ios"], name) ? 1 : 0) &&
        length(one(policy.rules).required_code_scanning) == 0
      )
    ])
    error_message = "Default policies preserve current reviews, signatures, owner exception, and the qualified Sanitizer and Travel check blocks."
  }
  assert {
    condition = (
      one(one(github_repository_ruleset.ios_products_default["document-sanitizer-ios"].rules).required_status_checks).strict_required_status_checks_policy &&
      !one(one(github_repository_ruleset.ios_products_default["document-sanitizer-ios"].rules).required_status_checks).do_not_enforce_on_create &&
      { for check in one(one(github_repository_ruleset.ios_products_default["document-sanitizer-ios"].rules).required_status_checks).required_check : check.context => check.integration_id } == {
        "macOS core, independent export corpus, iOS build" = 15368
        "Russian iPad privacy at system AX5"               = 15368
        "Native StoreKit eight-case acceptance"            = 15368
        "Exact packaged Release share smoke"               = 15368
        "analyze / CodeQL Analysis"                        = 15368
        "Swift security analysis"                          = 15368
        "CodeQL"                                           = 57789
      }
    )
    error_message = "Sanitizer needs all six Actions jobs plus the CodeQL app result, bound to their observed apps and current base."
  }
  assert {
    condition = (
      one(one(github_repository_ruleset.ios_products_default["travel-documents-ios"].rules).required_status_checks).strict_required_status_checks_policy &&
      !one(one(github_repository_ruleset.ios_products_default["travel-documents-ios"].rules).required_status_checks).do_not_enforce_on_create &&
      { for check in one(one(github_repository_ruleset.ios_products_default["travel-documents-ios"].rules).required_status_checks).required_check : check.context => check.integration_id } == {
        "CI gate"                   = 15368
        "analyze / CodeQL Analysis" = 15368
        "Swift security analysis"   = 15368
        "CodeQL"                    = 57789
      }
    )
    error_message = "Travel requires its complete native acceptance gate and both source analyses, bound to the observed apps and current base."
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
      for update in github_repository_dependabot_security_updates.ios_products : !update.enabled
    ])
    error_message = "Every new repository must retain vulnerability alerts while Renovate owns security updates."
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
