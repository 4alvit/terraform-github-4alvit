# Dedicated private repository. Its application workflows select only the
# repository-scoped self-hosted runner on h7; no hosted runner is required.
# Enabling alerts also enables GitHub's dependency graph and its hosted updater.
# Keep alerts disabled so a later Terraform apply cannot restore hosted jobs.
# The dependency graph itself was disabled in this repository's Settings UI;
# integrations/github 6.13 has no resource/attribute for that setting.
# Dependency audits and security checks run in the application's self-hosted CI.
resource "github_repository_vulnerability_alerts" "robinhood" {
  repository = module.repos["robinhood"].repository.name
  enabled    = false
}

# Automatic Dependabot updater jobs cannot run on this ARM64-only runner.
# Dependency auditing and update validation run in the application's self-hosted CI.
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
