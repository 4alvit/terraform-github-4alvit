# Dedicated private repository. Its application workflows select only the
# repository-scoped self-hosted runner on h7; no hosted runner is required.
resource "github_repository_vulnerability_alerts" "robinhood" {
  repository = module.repos["robinhood"].repository.name
  enabled    = true
}

resource "github_repository_dependabot_security_updates" "robinhood" {
  repository = module.repos["robinhood"].repository.id
  enabled    = true

  depends_on = [github_repository_vulnerability_alerts.robinhood]
}

resource "github_actions_repository_permissions" "robinhood" {
  repository           = module.repos["robinhood"].repository.name
  enabled              = true
  allowed_actions      = "all"
  sha_pinning_required = true
}
