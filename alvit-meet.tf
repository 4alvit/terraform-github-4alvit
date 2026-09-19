import {
  to = module.repos["alvit_meet"].github_repository.this
  id = "alvit-meet"
}

resource "github_repository_vulnerability_alerts" "alvit_meet" {
  repository = module.repos["alvit_meet"].repository.name
}

resource "github_repository_dependabot_security_updates" "alvit_meet" {
  repository = module.repos["alvit_meet"].repository.id
  enabled    = true
}
