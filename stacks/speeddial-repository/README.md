# Speed Dial repository

This Terraform root owns the private `4alvit/speeddial` repository,
vulnerability alerts and Dependabot security updates. It has a separate backend
and must remain the sole state owner of those objects. It neither imports nor
changes the top-level canonical state.

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
initial application must contain exactly three creates, with no changes,
destroys or imports. Later changes must preserve the repository identity and
visibility. Do not reapply an initial-create plan to an existing deployment or
add these resources to another root. Keep plans and state outside source control
and verify a no-change plan after an approved apply.

Repository destruction is guarded by `prevent_destroy` while its resource block
remains present. That safeguard is not a substitute for reviewing configuration
removal. Source publication and application deployment are separate operations.

From the repository root, `bash scripts/ci.sh` validates the configured roots
without backend access. Keep the complete resource inventory and deployment
receipts with the operator's protected configuration, outside public documentation.
