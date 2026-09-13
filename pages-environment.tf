# Adopt the existing Pages environment and its two branch policies unchanged.
resource "github_repository_environment" "profile_pages" {
  repository        = module.repos["iot_project_builder_profile"].repository.name
  environment       = "github-pages"
  can_admins_bypass = true
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "profile_pages" {
  for_each       = toset(["gh-pages", "main"])
  repository     = module.repos["iot_project_builder_profile"].repository.name
  environment    = github_repository_environment.profile_pages.environment
  branch_pattern = each.value
}

import {
  to = github_repository_environment.profile_pages
  id = "iot-project-builder-profile:github-pages"
}

import {
  to = github_repository_environment_deployment_policy.profile_pages["gh-pages"]
  id = "iot-project-builder-profile:github-pages:58321893"
}

import {
  to = github_repository_environment_deployment_policy.profile_pages["main"]
  id = "iot-project-builder-profile:github-pages:58321894"
}
