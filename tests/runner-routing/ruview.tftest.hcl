mock_provider "github" {
  override_during = plan
  mock_data "github_user" {
    defaults = { login = "4alvit" }
  }
}
run "self_hosted_routes_to_distinct_ephemeral_pools" {
  command = plan
  assert {
    condition = (
      github_actions_variable.runner["CI_RUNNER_MODE"].value == "self-hosted" &&
      github_actions_variable.runner["CI_RUNNER_LABELS"].value == jsonencode(["private-9f95fd05bbfc-ci"]) &&
      github_actions_variable.runner["CI_RUNNER_ARM64_LABELS"].value == jsonencode(["private-9f95fd05bbfc-arm64"]) &&
      github_actions_variable.runner["CI_RUNNER_AUTOMATION_LABELS"].value == jsonencode(["private-9f95fd05bbfc-automation"])
    )
    error_message = "The default route must match qualified repository-scoped ARC fleet pools."
  }
  assert {
    condition     = length(github_actions_variable.runner) == 4 && github_repository.ruview.visibility == "private"
    error_message = "Do not add another variable owner or change repository visibility."
  }
}
run "github_switch_preserves_ready_pool_labels" {
  command = plan
  variables { ci_runner_mode = "github" }
  assert {
    condition = (
      github_actions_variable.runner["CI_RUNNER_MODE"].value == "github" &&
      github_actions_variable.runner["CI_RUNNER_LABELS"].value == jsonencode(["private-9f95fd05bbfc-ci"])
    )
    error_message = "Hosted mode must preserve the prepared return route."
  }
}
run "legacy_k3s_alias_is_supported" {
  command = plan
  variables { ci_runner_mode = "k3s" }
  assert {
    condition     = github_actions_variable.runner["CI_RUNNER_MODE"].value == "k3s"
    error_message = "The k3s compatibility alias must remain available."
  }
}
run "unknown_or_automatic_backend_is_rejected" {
  command = plan
  variables { ci_runner_mode = "auto" }
  expect_failures = [var.ci_runner_mode]
}
