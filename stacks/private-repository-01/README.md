# Independent repository stack

This Terraform root owns the repository declared in its configuration,
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

Review a fresh, complete saved plan and apply only those accepted bytes. This root adopts the configuration of an existing deployment, so its first
validation must produce a no-change plan against the original state. Stop if
Terraform proposes any create, update, destroy or import. Do not add these
resources to another state owner. Keep plans and state outside source control
and verify a no-change plan after an approved apply.

Repository destruction is guarded by `prevent_destroy` while its resource block
remains present. That safeguard is not a substitute for reviewing configuration
removal. Source publication and application deployment are separate operations.

From the repository root, `bash scripts/ci.sh` validates the configured roots
without backend access. Keep the complete resource inventory and deployment
receipts with the operator's protected configuration, outside public documentation.

The protected workspace supplies the sensitive `private_repository` object and
the CLI environment selects that same existing backend. Resource addresses stay
unchanged. Never initialize against a different workspace or omit this input.

With local execution, HCP workspace variables are not automatically injected into
the CLI. Keep the sensitive object in a protected file outside this repository and
pass it explicitly with `-var-file`. Set `TF_CLOUD_ORGANIZATION` and `TF_WORKSPACE`
from the protected deployment record before `init`; preserve the original state
lineage. Never commit a workspace identity, variable values, saved plan or state.
