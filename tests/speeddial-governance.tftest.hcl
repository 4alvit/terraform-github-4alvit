mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      name       = "speeddial"
      visibility = "public"
      archived   = false
    }
  }
}

# The import remains part of the test configuration. Supply its existing
# identity locally because mock providers cannot perform remote imports.
override_resource {
  target = github_repository_ruleset.speeddial_main
  values = {
    id         = "speeddial:25988957"
    ruleset_id = 25988957
  }
}

variables {
  github_organization = "4alvit"
}

run "adopt_existing_main_policy_with_owner_only_bypass" {
  command = plan
  assert {
    condition = (
      github_repository_ruleset.speeddial_main.name == "Public main review and CI" &&
      github_repository_ruleset.speeddial_main.repository == "speeddial" &&
      github_repository_ruleset.speeddial_main.target == "branch" &&
      github_repository_ruleset.speeddial_main.enforcement == "active" &&
      one(one(github_repository_ruleset.speeddial_main.conditions).ref_name).include == tolist(["refs/heads/main"]) &&
      length(one(one(github_repository_ruleset.speeddial_main.conditions).ref_name).exclude) == 0 &&
      length(github_repository_ruleset.speeddial_main.bypass_actors) == 1 &&
      one(github_repository_ruleset.speeddial_main.bypass_actors).actor_type == "User" &&
      one(github_repository_ruleset.speeddial_main.bypass_actors).actor_id == 272257197 &&
      one(github_repository_ruleset.speeddial_main.bypass_actors).bypass_mode == "always"
    )
    error_message = "The existing main-only policy must grant permanent bypass only to the declared owner."
  }
  assert {
    condition = (
      one(github_repository_ruleset.speeddial_main.rules).deletion &&
      one(github_repository_ruleset.speeddial_main.rules).non_fast_forward &&
      !coalesce(one(github_repository_ruleset.speeddial_main.rules).required_signatures, false) &&
      one(one(github_repository_ruleset.speeddial_main.rules).pull_request).allowed_merge_methods == tolist(["merge", "squash", "rebase"]) &&
      one(one(github_repository_ruleset.speeddial_main.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.speeddial_main.rules).pull_request).dismiss_stale_reviews_on_push &&
      !one(one(github_repository_ruleset.speeddial_main.rules).pull_request).require_code_owner_review &&
      !one(one(github_repository_ruleset.speeddial_main.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.speeddial_main.rules).pull_request).required_review_thread_resolution &&
      length(one(one(github_repository_ruleset.speeddial_main.rules).pull_request).required_reviewers) == 0
    )
    error_message = "Adoption must retain the existing review, merge-method and history protections."
  }
  assert {
    condition = (
      one(one(github_repository_ruleset.speeddial_main.rules).required_status_checks).strict_required_status_checks_policy &&
      !one(one(github_repository_ruleset.speeddial_main.rules).required_status_checks).do_not_enforce_on_create &&
      length(one(one(github_repository_ruleset.speeddial_main.rules).required_status_checks).required_check) == 1 &&
      one(one(one(github_repository_ruleset.speeddial_main.rules).required_status_checks).required_check).context == "Application checks" &&
      coalesce(one(one(one(github_repository_ruleset.speeddial_main.rules).required_status_checks).required_check).integration_id, 0) == 0
    )
    error_message = "The strict Application checks requirement must keep its existing unrestricted integration source."
  }
}

run "private_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.speeddial
    values = {
      name       = "speeddial"
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [github_repository_ruleset.speeddial_main]
}

run "archived_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.speeddial
    values = {
      name       = "speeddial"
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [github_repository_ruleset.speeddial_main]
}

run "wrong_owner_is_rejected" {
  command = plan
  variables {
    github_organization = "another-owner"
  }
  expect_failures = [github_repository_ruleset.speeddial_main]
}
