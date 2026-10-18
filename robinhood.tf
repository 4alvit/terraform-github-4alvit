# Private repository. Application workflows use CI_RUNNER_MODE to choose
# GitHub-hosted compute or repository-scoped ephemeral ARC workers.
# Keep the existing dependency-alert/updater policy during the runner migration;
# changing Actions routing does not qualify the separate Dependabot updater.
# The dependency graph itself was disabled in the repository Settings UI;
# integrations/github 6.13 has no resource/attribute for that setting.
# Dependency audits and security checks remain in the application CI.
resource "github_repository_vulnerability_alerts" "robinhood" {
  repository = module.repos["robinhood"].repository.name
  enabled    = false
}

# Dependabot updater execution is separate from the Actions ARC pools. Keep it
# disabled until separately qualified; application CI still audits dependencies.
resource "github_repository_dependabot_security_updates" "robinhood" {
  repository = module.repos["robinhood"].repository.id
  enabled    = false

  depends_on = [github_repository_vulnerability_alerts.robinhood]
}

resource "github_actions_repository_permissions" "robinhood" {
  repository           = module.repos["robinhood"].repository.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}
