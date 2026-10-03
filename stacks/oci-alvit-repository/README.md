# OCI Alvit repository

This independent Terraform root owns exactly three new resources: private
`4alvit/terraform-oracle-oci-alvit`, vulnerability alerts and Dependabot security
updates. It does not adopt or move any resources managed by the top-level root.

State: [victron-venus/github-oci-alvit-repository](https://app.terraform.io/app/victron-venus/workspaces/github-oci-alvit-repository).
Workspace ID: `ws-gmFCCGeKN6e8ZbYK`. The initial application on 2026-10-02 Pacific
created all three resources, with no changes or deletions.
Use local execution with auto-apply disabled and the current HCP account's
existing credentials. GitHub authentication is separate: the token must belong
to `4alvit`, which the configuration checks before creating the repository.

Run Terraform from this directory. Load `GITHUB_TOKEN` from the existing private
credential store into the process environment; never store it in source or
Terraform variables. Clear `GITHUB_OWNER` and `GITHUB_ORGANIZATION` from that
environment before running Terraform: provider 6.x allows these to override
the configured owner. Also clear inherited `TF_CLI_ARGS*` overrides.

Initialize the backend and inspect a fresh, complete saved plan before applying
that exact plan. The initial deployment must contain **3 creates, 0 changes,
0 destroys and no imports**, for only the resources above. Subsequent deployment
must preserve repository identity and private visibility. Keep saved plans and
plan JSON outside source control in a private directory. Verify a no-change
plan after applying. `prevent_destroy` protects the repository while its resource
block remains in this configuration.

From the repository root, `bash scripts/ci.sh` validates both Terraform roots
using disposable directories with backend access disabled.
