# These new public repositories belong only to the canonical top-level state.
# Do not include them in the live-data public/release sets before creation.
locals {
  ios_product_repositories = {
    room-inventory-ios = {
      description = "Local-first iOS room inventory with confirmed OCR suggestions, document attachments, and portable exports"
      topics      = ["home-inventory", "ios", "local-first", "ocr", "swift", "swiftui"]
    }
    document-sanitizer-ios = {
      description = "Local-first iOS document preparation with explicit redaction and metadata removal"
      topics      = ["documents", "ios", "local-first", "privacy", "swift", "swiftui"]
    }
    travel-documents-ios = {
      description = "Local-first iOS travel document organizer with offline access and trip readiness checks"
      topics      = ["documents", "ios", "local-first", "swift", "swiftui", "travel"]
    }
  }
}

module "ios_products" {
  source   = "./modules/github_repo"
  for_each = local.ios_product_repositories

  name                   = each.key
  description            = each.value.description
  visibility             = "public"
  has_projects           = false
  has_wiki               = false
  allow_auto_merge       = true
  license_template       = "mit"
  enable_public_security = true
  topics                 = each.value.topics
}

# The MIT template seeds the repository. Normalize the resulting default branch
# before installing branch rules; clients must fetch this seed before first push.
resource "github_branch_default" "ios_products" {
  for_each   = local.ios_product_repositories
  repository = module.ios_products[each.key].repository.name
  branch     = "main"
  rename     = true
}

resource "github_repository_vulnerability_alerts" "ios_products" {
  for_each   = local.ios_product_repositories
  repository = module.ios_products[each.key].repository.name
}

resource "github_repository_dependabot_security_updates" "ios_products" {
  for_each   = local.ios_product_repositories
  repository = module.ios_products[each.key].repository.name
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.ios_products]
}

resource "github_workflow_repository_permissions" "ios_products" {
  for_each                         = local.ios_product_repositories
  repository                       = module.ios_products[each.key].repository.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

# Preserve the existing account's approved automation reviewer convention.
# Live onboarding must verify acceptance/access before relying on its approval.
resource "github_repository_collaborator" "ios_products_automation" {
  for_each   = local.ios_product_repositories
  repository = module.ios_products[each.key].repository.name
  username   = "californiantiramisu"
  permission = "push"
}

resource "github_repository_ruleset" "ios_products_default" {
  for_each    = local.ios_product_repositories
  name        = "Default"
  repository  = module.ios_products[each.key].repository.name
  target      = "branch"
  enforcement = "active"

  # New public review rules follow the no-bypass policy in public-security.tf.
  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }
  rules {
    deletion            = true
    non_fast_forward    = true
    required_signatures = true
    pull_request {
      allowed_merge_methods             = ["merge", "squash", "rebase"]
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
  }

  depends_on = [github_branch_default.ios_products]
}

# Versioned releases must remain immutable, including prereleases.
resource "github_repository_ruleset" "ios_products_version_tags" {
  for_each    = local.ios_product_repositories
  name        = "Immutable version tags"
  repository  = module.ios_products[each.key].repository.name
  target      = "tag"
  enforcement = "active"
  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }
  rules {
    deletion         = true
    update           = true
    non_fast_forward = true
  }
}

output "ios_product_repositories" {
  description = "Public iOS product repository URLs; application releases are managed by each product."
  value = {
    for name, product in module.ios_products : name => {
      url            = product.repository.html_url
      ssh_clone_url  = product.repository.ssh_clone_url
      default_branch = github_branch_default.ios_products[name].branch
    }
  }
}
