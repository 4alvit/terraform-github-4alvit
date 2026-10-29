mock_provider "github" {
  override_during = plan
}

variables {
  name        = "branch-cleanup-fixture"
  description = "Disposable mock-plan fixture"
}

run "enabled_by_default" {
  command = plan
  assert {
    condition     = github_repository.this.delete_branch_on_merge
    error_message = "Every managed repository must delete merged branches by default."
  }
}

run "explicitly_enabled" {
  command = plan
  variables {
    delete_branch_on_merge = true
  }
  assert {
    condition     = github_repository.this.delete_branch_on_merge
    error_message = "Explicitly enabled cleanup must remain enabled."
  }
}

run "private_repository_enabled" {
  command = plan
  variables {
    visibility = "private"
  }
  assert {
    condition     = github_repository.this.delete_branch_on_merge
    error_message = "Private repositories have the same merged-branch cleanup policy."
  }
}

run "null_uses_enabled_default" {
  command = plan
  variables {
    delete_branch_on_merge = null
  }
  assert {
    condition     = github_repository.this.delete_branch_on_merge
    error_message = "A null input must not remove the cleanup policy."
  }
}

run "disabled_cleanup_is_rejected" {
  command = plan
  variables {
    delete_branch_on_merge = false
  }
  expect_failures = [var.delete_branch_on_merge]
}
