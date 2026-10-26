mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      name       = "cisco-home-telephony"
      visibility = "public"
      archived   = false
    }
  }
}

variables {
  github_organization = "4alvit"
}

run "one_current_review_and_actual_ci_without_bypass" {
  command = plan
  assert {
    condition = (
      github_repository_collaborator.automation_bot["cisco-home-telephony"].repository == "cisco-home-telephony" &&
      github_repository_collaborator.automation_bot["cisco-home-telephony"].username == "californiantiramisu" &&
      github_repository_collaborator.automation_bot["cisco-home-telephony"].permission == "push"
    )
    error_message = "The existing automation account needs write access for its approval to satisfy branch protection."
  }
  assert {
    condition = (
      github_repository_ruleset.cisco_main.repository == "cisco-home-telephony" &&
      github_repository_ruleset.cisco_main.target == "branch" &&
      github_repository_ruleset.cisco_main.enforcement == "active" &&
      length(github_repository_ruleset.cisco_main.bypass_actors) == 0 &&
      one(one(github_repository_ruleset.cisco_main.conditions).ref_name).include == tolist(["~DEFAULT_BRANCH"])
    )
    error_message = "Only the default branch of the existing Cisco repository is protected, without bypass actors."
  }
  assert {
    condition = (
      one(github_repository_ruleset.cisco_main.rules).deletion &&
      one(github_repository_ruleset.cisco_main.rules).non_fast_forward &&
      one(one(github_repository_ruleset.cisco_main.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.cisco_main.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.cisco_main.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.cisco_main.rules).pull_request).required_review_thread_resolution
    )
    error_message = "Force pushes/deletions and stale or missing reviews must block merges."
  }
  assert {
    condition = (
      one(one(github_repository_ruleset.cisco_main.rules).required_status_checks).strict_required_status_checks_policy &&
      !one(one(github_repository_ruleset.cisco_main.rules).required_status_checks).do_not_enforce_on_create &&
      toset([for check in one(one(github_repository_ruleset.cisco_main.rules).required_status_checks).required_check : check.context]) == toset(["validate", "Wake gate"]) &&
      alltrue([for check in one(one(github_repository_ruleset.cisco_main.rules).required_status_checks).required_check : check.integration_id == 15368])
    )
    error_message = "Require the two always-emitted actual GitHub Actions checks, not a nonexistent CI gate or path-filtered build."
  }
}

run "private_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.cisco_home_telephony
    values = {
      name       = "cisco-home-telephony"
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [github_repository_ruleset.cisco_main]
}

run "archived_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.cisco_home_telephony
    values = {
      name       = "cisco-home-telephony"
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [github_repository_ruleset.cisco_main]
}

run "wrong_owner_is_rejected" {
  command = plan
  variables {
    github_organization = "another-owner"
  }
  expect_failures = [github_repository_ruleset.cisco_main]
}
