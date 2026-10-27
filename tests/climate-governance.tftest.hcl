mock_provider "github" {
  override_during = plan
  mock_data "github_user" {
    defaults = { login = "4alvit", id = "272257197" }
  }
}

run "owner_exception_preserves_existing_administrator_grant" {
  command = plan
  assert {
    condition = (
      local.owner_emergency_merge_actor.actor_type == "OrganizationAdmin" &&
      local.owner_emergency_merge_actor.actor_id == null &&
      local.owner_emergency_merge_actor.bypass_mode == "pull_request" &&
      length(github_repository_ruleset.climate.bypass_actors) == 2 &&
      length([
        for actor in github_repository_ruleset.climate.bypass_actors : actor
        if actor.actor_type == "RepositoryRole" && actor.actor_id == 5 && actor.bypass_mode == "pull_request"
      ]) == 1 &&
      length([
        for actor in github_repository_ruleset.climate.bypass_actors : actor
        if actor.actor_type == "OrganizationAdmin" && coalesce(actor.actor_id, 0) == 0 && actor.bypass_mode == "pull_request"
      ]) == 1
    )
    error_message = "Add the owner emergency PR path without replacing the existing administrator PR exception."
  }
}

run "review_ci_tags_and_release_approval_are_unchanged" {
  command = plan
  assert {
    condition = (
      one(one(github_repository_ruleset.climate.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.climate.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.climate.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.climate.rules).pull_request).required_review_thread_resolution &&
      one(one(github_repository_ruleset.climate.rules).required_status_checks).strict_required_status_checks_policy &&
      one(one(one(github_repository_ruleset.climate.rules).required_status_checks).required_check).context == "CI gate" &&
      one(one(one(github_repository_ruleset.climate.rules).required_status_checks).required_check).integration_id == 15368 &&
      length(github_repository_ruleset.immutable_release_tags.bypass_actors) == 0 &&
      one(github_repository_ruleset.immutable_release_tags.rules).deletion &&
      one(github_repository_ruleset.immutable_release_tags.rules).update &&
      one(github_repository_ruleset.immutable_release_tags.rules).non_fast_forward &&
      one(github_repository_environment.release.reviewers).users == toset([272257197]) &&
      one(github_repository_environment.release.deployment_branch_policy).custom_branch_policies &&
      github_repository_environment_deployment_policy.release.branch_pattern == "main"
    )
    error_message = "Keep the versioned current-review policy, strict CI, immutable tags and existing main-only release approval."
  }
}
