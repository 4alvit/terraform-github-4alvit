# Claude harness repository

This independent Terraform root owns exactly three new resources: private
`4alvit/claude-harness`, vulnerability alerts, and Dependabot security updates.
It does not adopt or move any resources managed by another Terraform root.

State: [victron-venus/github-claude-harness-repository](https://app.terraform.io/app/victron-venus/workspaces/github-claude-harness-repository).
Workspace ID: `ws-ohHv8fx3SVKN37PR`. The workspace was created on 2026-10-03
with local execution, Terraform 1.15.7, and auto-apply disabled.
The initial application on 2026-10-03 created all three resources with no changes,
deletions, or imports. A complete post-apply plan returned exit code `0` (no changes).
Use the current HCP account's
existing credentials. GitHub authentication is separate: the token must belong
to `4alvit`, which the configuration checks before creating the repository.

The owner requested a separate private harness repository. Following the existing
OCI Alvit repository stack, this root gives those new objects one explicit state
owner in the accessible HCP organization. A read-only access check for the
canonical personal workspace returned HTTP 404 on 2026-10-03; that result does
not establish whether the workspace is absent or inaccessible. This root is not
a replacement for that workspace, a backend migration, or an empty-state retry
of the top-level configuration. Do not add these resources to the top-level
root or import existing repositories into this workspace.

Run Terraform from this directory. Load `GITHUB_TOKEN` from the existing private
credential store into the process environment; never store it in source or
Terraform variables. Both `owner` and the legacy `organization` provider argument
are pinned to `4alvit` because provider 6.x checks the legacy argument before
inherited `GITHUB_OWNER`, `GITHUB_ORGANIZATION`, or the `owner` attribute.
Keep the legacy argument until a provider major upgrade verifies configuration
precedence. Clear inherited `TF_CLI_ARGS*` overrides.

Initialize the backend and inspect a fresh, complete saved plan before applying
that exact plan. Initial deployment must contain **3 creates, 0 changes,
0 destroys, and no imports**, for only the resources above. Keep saved plans and
plan JSON outside source control in a private directory. Verify a no-change
plan after applying. Subsequent deployment must preserve repository identity
and private visibility. `prevent_destroy` protects the repository while its
resource block remains in this configuration; `archive_on_destroy` is a separate
provider safeguard if an intentional lifecycle change permits destruction.

The repository starts empty, without an automatically selected license or
bootstrap commit. Source publication, branches, and pull requests are separate
Git operations. Automatic PR merging, projects, wiki, and discussions are disabled.

From the repository root, `bash scripts/ci.sh` validates the configured Terraform
roots in disposable directories with backend access disabled. The owner
regression also exercises this stack's provider settings against a synthetic
API on `127.0.0.1`, including conflicting inherited owner values and a negative
control. That fixture has no managed resources, backend, or real credentials;
it does not plan against GitHub or HCP infrastructure.
