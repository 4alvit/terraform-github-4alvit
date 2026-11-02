# Room release activation

`room-release.tf` belongs to the existing canonical
`alvit-infrastructure/github-4alvit-infrastructure` workspace. It adds exactly
three managed objects for the public `4alvit/room-inventory-ios` repository:

- `github_repository_environment.room_release`: environment `release`, required
  reviewer `californiantiramisu` (user ID `319626568`), self-review permitted and
  administrator bypass retained under the shared release policy.
- `github_repository_environment_deployment_policy.room_release`: selected
  branch `main` only, without a tag policy.
- `github_actions_variable.room_release_channels_enabled`:
  `RELEASE_CHANNELS_ENABLED=false` by default.

This is not a mandatory two-person approval policy. Reviewer Write access must be
verified before applying. The existing `ios_products_version_tags` resource owns
Room's immutable version tags; do not create another tag ruleset through
`release_channel_repositories`. This change installs no additional CI ruleset,
production environment, signing credentials, or App Store configuration. It does
not change the other two iOS repositories or shared release workflows.

## Activation conditions

First follow the [HCP account-selection runbook](hcp-account-selection.md).
Use the existing named `4alvit` profile, verify its immutable account identity
and exact `alvit-infrastructure` / `ws-AKy7NQFpKuV5KHyr` ownership before each
plan/apply, and pass that same credential only to the selected command. Never
fall back to the default account after a 404. Authentication does not qualify
the workspace's remote execution runtime or authorize a resource change.

Keep publication disabled while the application PR is under review. Before any
activation, verify the approved application workflows are merged into `main`,
the exact resulting source revision has successful required quality/security and
recovery checks, and the release build/qualification path is ready. A successful
PR run alone is not evidence that the workflow is installed on the default branch.

Read repository hooks with administrator access. Existing production handlers
for release, push, tag creation or CI completion must be disabled or migrated
before candidate publication. An empty repository-hook response proves only the
absence of repository webhook objects at that instant; it does not inventory
external pollers or GitHub App integrations. Check the source release workflows
for production deployment consumers and retain the readback evidence privately.

Confirm Room retains repository ID `1432741511`, is public, active and defaulted
to `main`, the reviewer identity
and effective Write access are unchanged, and the existing tag protection remains
active. Require the environment and branch policy to be absent from live inventory
and canonical state before creation. If a workflow has created an unprotected
environment in the meantime, review its import instead of creating duplicate state.

Review a plan against the canonical state containing only these three resource
addresses. Reject unrelated changes, deletes, replacements, imports or ruleset
changes. Initial provisioning must set the variable to false. Verify the resulting
live environment and branch policy, then obtain a separate activation GO and
review a plan changing only the variable to true. Do not combine initial creation
and publication enablement. The variable also depends on completion of the
environment's branch policy.

Persist the approved activation by setting `room_release_channels_enabled: true`
in the tracked `release-activation.auto.tfvars.json`; do not rely on an ephemeral
CLI override that the next ordinary plan would undo. Preserve all other entries.
After apply, read back the three objects and run an unrestricted canonical plan;
a targeted plan alone cannot establish absence of fleet drift.

## Publication behavior

Changing the variable does not itself dispatch a workflow. Subsequent eligible
default-branch pushes can publish beta and scheduled runs can publish nightly.
Nightly/beta/RC candidate jobs do not use the `release` environment; required
environment approval applies only to stable promotion. Manual beta/RC/stable
requests fail while the variable is disabled. Stable additionally requires
acceptance of the exact RC and verification of its retained artifact evidence.

GitHub artifacts remain source plus an unsigned iOS Simulator preview, not a
device-installable IPA or an App Store release. Apple signing, account agreements,
production StoreKit setup and review require their separate authorized process.
