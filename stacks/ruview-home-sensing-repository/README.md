# Independent repository stack

This Terraform root owns the repository declared in its configuration,
vulnerability alerts, Dependabot security updates and its CI routing variables.
It has a separate backend and must remain the sole state owner of those objects.
It neither imports nor changes the top-level canonical state.

Run Terraform from this directory. Verify the configured backend and authorized
HCP identity before initialization. Use local execution with auto-apply disabled
where required by the backend configuration. Load `GITHUB_TOKEN` from the
operator's credential store into the process environment; never store it in
source or saved public plan output. The configured GitHub account check must
succeed before creating resources.

The provider configuration pins `owner` and the legacy `organization` argument
to prevent inherited owner variables from redirecting provider 6.x. Keep that
compatibility setting until a provider upgrade validates precedence. Clear
inherited `TF_CLI_ARGS*` overrides before preparing a plan.

Review a fresh, complete saved plan and apply only those accepted bytes. An
initial application must contain exactly six creates, with no changes,
destroys or imports. Later changes must preserve the repository identity and
visibility. Do not reapply an initial-create plan to an existing deployment or
add these resources to another root. Keep plans and state outside source control
and verify a no-change plan after an approved apply.

## CI runner routing

The existing HCP workspace is
`victron-venus/github-ruview-home-sensing-repository`. Do not move these variables
to the top-level state or create a second repository stack.

`ci_runner_mode` defaults to `self-hosted`; `k3s` is an equivalent mode. Its
validated rollback value is `github`. The managed Actions variables are:

- `CI_RUNNER_MODE`: the selected mode.
- `CI_RUNNER_LABELS`: `["self-hosted","Linux","X64","ruview-ci"]` for x64 jobs.
- `CI_RUNNER_ARM64_LABELS`: `["self-hosted","Linux","ARM64","ruview-ci"]` for native ARM64 jobs.

Both architecture-specific registrations must be available to this repository
and qualified before enabling self-hosted mode. These variables do not install
or register runners. The RuView workflows must consume the selectors; setting a
variable does not change a literal `runs-on`. New runs use the selected mode;
existing queued or failed runs are not moved automatically. Repositories owned
by the personal `4alvit` account do not inherit organization-level variables.

When adopting routing for the existing repository, review a complete plan from
this directory: it should create only the three `github_actions_variable.runner`
instances and preserve every existing resource. Investigate any other drift
before applying; do not use `-target` to hide it. Keep a saved plan outside the
checkout and apply those reviewed bytes. Before the runners are qualified, plan
with `-var='ci_runner_mode=github'` to keep hosted execution. To restore hosted
execution later, use the same override for a fresh plan and apply the reviewed
plan. Do not change either architecture label to borrow an unrelated pool.

Repository destruction is guarded by `prevent_destroy` while its resource block
remains present. That safeguard is not a substitute for reviewing configuration
removal. Source publication and application deployment are separate operations.

From the repository root, `bash scripts/ci.sh` validates the configured roots
without backend access. Keep the complete resource inventory and deployment
receipts with the operator's protected configuration, outside public documentation.
