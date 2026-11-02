mock_provider "github" {
  override_during = plan

  mock_data "github_repository" {
    defaults = {
      repo_id        = 1432741511
      name           = "room-inventory-ios"
      visibility     = "public"
      archived       = false
      default_branch = "main"
    }
  }
  mock_data "github_user" {
    defaults = { id = "319626568" }
  }
}

run "publication_disabled_and_protected" {
  command = plan
  assert {
    condition = (
      github_repository_environment.room_release.repository == "room-inventory-ios" &&
      github_repository_environment.room_release.environment == "release" &&
      one(github_repository_environment.room_release.reviewers).users == toset([319626568]) &&
      !github_repository_environment.room_release.prevent_self_review &&
      github_repository_environment.room_release.can_admins_bypass &&
      !one(github_repository_environment.room_release.deployment_branch_policy).protected_branches &&
      one(github_repository_environment.room_release.deployment_branch_policy).custom_branch_policies &&
      github_repository_environment_deployment_policy.room_release.branch_pattern == "main" &&
      github_repository_environment_deployment_policy.room_release.tag_pattern == null &&
      github_actions_variable.room_release_channels_enabled.repository == "room-inventory-ios" &&
      github_actions_variable.room_release_channels_enabled.variable_name == "RELEASE_CHANNELS_ENABLED" &&
      github_actions_variable.room_release_channels_enabled.value == "false"
    )
    error_message = "Room must start with publication disabled, the verified reviewer and a main-branch-only policy."
  }
}

run "explicit_publication_opt_in" {
  command = plan
  variables { room_release_channels_enabled = true }
  assert {
    condition     = github_actions_variable.room_release_channels_enabled.value == "true"
    error_message = "Only explicit opt-in enables candidate publication."
  }
}

run "reject_private_repository" {
  command = plan
  override_data {
    target = data.github_repository.room_release
    values = {
      repo_id    = 1432741511, name = "room-inventory-ios",
      visibility = "private", archived = false, default_branch = "main"
    }
  }
  expect_failures = [data.github_repository.room_release]
}

run "reject_changed_default_branch" {
  command = plan
  override_data {
    target = data.github_repository.room_release
    values = {
      repo_id    = 1432741511, name = "room-inventory-ios",
      visibility = "public", archived = false, default_branch = "develop"
    }
  }
  expect_failures = [data.github_repository.room_release]
}

run "reject_reviewer_identity_change" {
  command = plan
  override_data {
    target = data.github_user.room_release_reviewer
    values = { id = "1" }
  }
  expect_failures = [data.github_user.room_release_reviewer]
}

run "reject_recreated_repository" {
  command = plan
  override_data {
    target = data.github_repository.room_release
    values = {
      repo_id    = 1, name = "room-inventory-ios",
      visibility = "public", archived = false, default_branch = "main"
    }
  }
  expect_failures = [data.github_repository.room_release]
}

run "reject_archived_repository" {
  command = plan
  override_data {
    target = data.github_repository.room_release
    values = {
      repo_id    = 1432741511, name = "room-inventory-ios",
      visibility = "public", archived = true, default_branch = "main"
    }
  }
  expect_failures = [data.github_repository.room_release]
}

run "reject_foreign_owner" {
  command = plan
  variables { github_organization = "another-owner" }
  override_data {
    target = data.github_repository.room_release
    values = {
      repo_id    = 1432741511, name = "room-inventory-ios",
      visibility = "public", archived = false, default_branch = "main"
    }
  }
  expect_failures = [data.github_repository.room_release]
}
