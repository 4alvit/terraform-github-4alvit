# Shared input contracts for the existing receiver; importing must not rotate it.
variable "portainer_push_webhook_url" {
  description = "Exact existing endpoint of terraform-portainer-synology webhook 675888988"
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = startswith(var.portainer_push_webhook_url, "https://")
    error_message = "Supply the existing HTTPS webhook endpoint through a sensitive workspace input."
  }
}

variable "portainer_push_webhook_secret" {
  description = "Existing live WEBHOOK_SECRET from the github-deploy-webhook receiver; do not rotate during import"
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition = (
      length(trimspace(var.portainer_push_webhook_secret)) >= 32 &&
      !can(regex("^\\*+$", var.portainer_push_webhook_secret))
    )
    error_message = "Supply the original receiver HMAC secret of at least 32 characters, not an API mask."
  }
}

