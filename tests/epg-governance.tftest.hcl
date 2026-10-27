mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      name       = "epg-voice-gateway"
      visibility = "public"
      archived   = false
    }
  }
}

variables {
  github_organization = "4alvit"
}

run "legacy_policy_parity_and_owner_only_pr_exception" {
  command = plan
  assert {
    condition = (
      github_repository_ruleset.epg_main.repository == "epg-voice-gateway" &&
      github_repository_ruleset.epg_main.target == "branch" &&
      github_repository_ruleset.epg_main.enforcement == "active" &&
      length(github_repository_ruleset.epg_main.bypass_actors) == 1 &&
      one(github_repository_ruleset.epg_main.bypass_actors).actor_type == "User" &&
      one(github_repository_ruleset.epg_main.bypass_actors).actor_id == 272257197 &&
      one(github_repository_ruleset.epg_main.bypass_actors).bypass_mode == "pull_request" &&
      one(one(github_repository_ruleset.epg_main.conditions).ref_name).include == tolist(["refs/heads/main"])
    )
    error_message = "Only the existing exact main branch and explicit owner may receive this PR-only exception."
  }
  assert {
    condition = (
      one(github_repository_ruleset.epg_main.rules).deletion &&
      one(github_repository_ruleset.epg_main.rules).non_fast_forward &&
      one(one(github_repository_ruleset.epg_main.rules).pull_request).required_approving_review_count == 1 &&
      !one(one(github_repository_ruleset.epg_main.rules).pull_request).dismiss_stale_reviews_on_push &&
      !one(one(github_repository_ruleset.epg_main.rules).pull_request).require_code_owner_review &&
      !one(one(github_repository_ruleset.epg_main.rules).pull_request).require_last_push_approval &&
      !one(one(github_repository_ruleset.epg_main.rules).pull_request).required_review_thread_resolution
    )
    error_message = "Migration must retain the legacy review and history protections exactly."
  }
  assert {
    condition = (
      one(one(github_repository_ruleset.epg_main.rules).required_status_checks).strict_required_status_checks_policy &&
      !one(one(github_repository_ruleset.epg_main.rules).required_status_checks).do_not_enforce_on_create &&
      length(one(one(github_repository_ruleset.epg_main.rules).required_status_checks).required_check) == 1 &&
      one(one(one(github_repository_ruleset.epg_main.rules).required_status_checks).required_check).context == "python" &&
      one(one(one(github_repository_ruleset.epg_main.rules).required_status_checks).required_check).integration_id == 15368
    )
    error_message = "Only the existing strict python check from GitHub Actions may gate ordinary merges."
  }
}

run "private_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.epg_voice_gateway
    values = {
      name       = "epg-voice-gateway"
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [github_repository_ruleset.epg_main]
}

run "archived_repository_is_rejected" {
  command = plan
  override_data {
    target = data.github_repository.epg_voice_gateway
    values = {
      name       = "epg-voice-gateway"
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [github_repository_ruleset.epg_main]
}

run "wrong_owner_is_rejected" {
  command = plan
  variables {
    github_organization = "another-owner"
  }
  expect_failures = [github_repository_ruleset.epg_main]
}
