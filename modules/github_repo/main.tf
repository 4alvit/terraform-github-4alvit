variable "name" {
  description = "Repository name (slug)."
  type        = string
}

variable "description" {
  description = "Short repository description."
  type        = string
}

variable "visibility" {
  description = "Repository visibility: public or private."
  type        = string
  default     = "public"
}

variable "has_issues" {
  type    = bool
  default = true
}

variable "has_projects" {
  type    = bool
  default = true
}

variable "has_wiki" {
  type    = bool
  default = true
}

variable "has_discussions" {
  type    = bool
  default = false
}

variable "allow_merge_commit" {
  type    = bool
  default = true
}

variable "allow_squash_merge" {
  type    = bool
  default = true
}

variable "allow_rebase_merge" {
  type    = bool
  default = true
}

variable "allow_auto_merge" {
  type    = bool
  default = true
}

variable "delete_branch_on_merge" {
  type    = bool
  default = true
}

variable "topics" {
  description = "List of repository topics."
  type        = list(string)
  default     = []
}

variable "license_template" {
  description = "License template slug (e.g. mit). Empty string = no license."
  type        = string
  default     = "mit"
}

resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  has_issues      = var.has_issues
  has_projects    = var.has_projects
  has_wiki        = var.has_wiki
  has_discussions = var.has_discussions

  allow_merge_commit = var.allow_merge_commit
  allow_squash_merge = var.allow_squash_merge
  allow_rebase_merge = var.allow_rebase_merge
  allow_auto_merge   = var.allow_auto_merge

  delete_branch_on_merge = var.delete_branch_on_merge

  topics = var.topics

  license_template = var.license_template
}

output "repository" {
  # Expose only the fields callers use. Exporting the full resource forces
  # Terraform to read every computed attribute, including the deprecated
  # `default_branch`. The provider now warns on that read and points users
  # at `github_branch_default` — we don't need the default branch here, so
  # we just stop asking for it.
  value = {
    name          = github_repository.this.name
    id            = github_repository.this.id
    html_url      = github_repository.this.html_url
    ssh_clone_url = github_repository.this.ssh_clone_url
  }
}
