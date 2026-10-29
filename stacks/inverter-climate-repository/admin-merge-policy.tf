# The declared owner may bypass branch rules for direct updates and history repair.
# Review, CI, signature and history rules continue to apply to other actors.
# Existing tag protections and deployment approvals are unchanged.
locals {
  owner_emergency_merge_actor = {
    actor_id    = null
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }
}
