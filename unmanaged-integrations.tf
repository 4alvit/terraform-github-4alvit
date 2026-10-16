# Adopt existing Actions settings without publishing their values in source.
# The canonical HCP workspace must supply the exact current GitHub values as
# sensitive Terraform inputs before planning or importing these resources.
variable "portainer_actions_endpoint_id" {
  description = "Existing ENDPOINT_ID Actions variable in 4alvit/terraform-portainer-synology"
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.portainer_actions_endpoint_id)) > 0
    error_message = "Supply the existing nonempty Portainer endpoint ID through a sensitive workspace input."
  }
}

variable "portainer_actions_url" {
  description = "Existing PORTAINER_URL Actions secret; preserve the exact URL from the sensitive workspace input"
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.portainer_actions_url)) > 0
    error_message = "Supply the existing nonempty Portainer URL through a sensitive workspace input."
  }
}

resource "github_actions_variable" "portainer_endpoint_id" {
  repository    = module.repos["terraform_portainer_synology"].repository.name
  variable_name = "ENDPOINT_ID"
  value         = var.portainer_actions_endpoint_id
}

# The old variable is removed separately after both workflow consumers use the
# secret. Forget its state entry without recreating or deleting a remote object.
removed {
  from = github_actions_variable.portainer_url

  lifecycle {
    destroy = false
  }
}

resource "github_actions_secret" "portainer_url" {
  repository      = module.repos["terraform_portainer_synology"].repository.name
  secret_name     = "PORTAINER_URL"
  plaintext_value = var.portainer_actions_url
}

import {
  to = github_actions_variable.portainer_endpoint_id
  id = "terraform-portainer-synology:ENDPOINT_ID"
}

import {
  to = github_actions_secret.portainer_url
  id = "terraform-portainer-synology/PORTAINER_URL"
}

# The existing receiver is Portainer stack 28 (github-deploy-webhook), owned by
# HCP workspace portainer-github-deploy-webhook. Reuse its live WEBHOOK_SECRET;
# this workspace owns the GitHub webhook object, not the receiver deployment.
# Keep webhook credentials separate from the repository-management token,
# whose current fine-grained permissions cannot read this private hook.
variable "github_webhook_token" {
  description = "Existing authorized GitHub credential with read/write repository webhooks access; supplied only through sensitive HCP input"
  type        = string
  sensitive   = true
  nullable    = false
}

provider "github" {
  alias = "webhook"
  owner = var.github_organization
  token = var.github_webhook_token
}

resource "github_repository_webhook" "portainer_push" {
  provider   = github.webhook
  repository = module.repos["terraform_portainer_synology"].repository.name
  active     = true
  events     = ["push"]

  configuration {
    url          = var.portainer_push_webhook_url
    secret       = var.portainer_push_webhook_secret
    content_type = "json"
    insecure_ssl = false
  }
}

import {
  to = github_repository_webhook.portainer_push
  id = "terraform-portainer-synology/675888988"
}
