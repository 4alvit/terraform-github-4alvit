terraform {
  required_version = ">= 1.15.7"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Fixture inputs are consumed when release policy source is copied into the test root.
# tflint-ignore: terraform_unused_declarations
variable "github_organization" {
  type    = string
  default = "release-contract-fixture"
}

# Exercise the actual infrastructure ruleset and its existing repository module
# with the same mocked provider; this fixture has no cloud backend or credentials.
module "repos" {
  for_each    = toset(["terraform_github_ha_homelab"])
  source      = "./modules/github_repo"
  name        = "terraform-github-ha-homelab"
  description = "Mocked review-policy fixture"
}
