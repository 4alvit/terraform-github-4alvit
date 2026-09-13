# Preserve and adopt the enabled security settings on existing repositories.
locals {
  adopted_security_repositories = toset(["4alvit", "demo", "home-assistant", "terraform-github-open-ott-play", "terraform-github-victron", "terraform-portainer-synology", "terraform-synology-alvit"])
}
resource "github_repository_vulnerability_alerts" "adopted" {
  for_each   = local.adopted_security_repositories
  repository = each.value
}
resource "github_repository_dependabot_security_updates" "adopted" {
  for_each   = local.adopted_security_repositories
  repository = each.value
  enabled    = true
}
import {
  for_each = local.adopted_security_repositories
  to       = github_repository_vulnerability_alerts.adopted[each.key]
  id       = each.value
}
import {
  for_each = local.adopted_security_repositories
  to       = github_repository_dependabot_security_updates.adopted[each.key]
  id       = each.value
}
