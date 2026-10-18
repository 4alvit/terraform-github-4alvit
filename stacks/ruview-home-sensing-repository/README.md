# Independent repository stack

This Terraform root owns the repository declared in its configuration,
vulnerability alerts, Dependabot security updates, workflow permissions and its CI routing variables.
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
initial application must contain exactly eight creates, with no changes,
destroys or imports. Later changes must preserve the repository identity and
visibility. Do not reapply an initial-create plan to an existing deployment or
add these resources to another root. Keep plans and state outside source control
and verify a no-change plan after an approved apply.

## CI runner routing

The existing HCP workspace is
`victron-venus/github-ruview-home-sensing-repository`. It remains the sole owner
of the four Actions routing variables. Do not create another state owner or
change these values only in GitHub: a later apply would restore this root's
configuration.

`ci_runner_mode` defaults to `self-hosted`; `k3s` is a compatibility alias.
`github` selects GitHub-hosted minutes. The deterministic ARC prefix is
`private-9f95fd05bbfc`, derived from the first 12 hexadecimal SHA-256 characters
of `4alvit/ruview-home-sensing`, matching the private fleet renderer:

- `CI_RUNNER_MODE`: the explicitly selected backend.
- `CI_RUNNER_LABELS`: `["private-9f95fd05bbfc-ci"]` for x64 build jobs.
- `CI_RUNNER_ARM64_LABELS`: `["private-9f95fd05bbfc-arm64"]` for native ARM64 jobs.
- `CI_RUNNER_AUTOMATION_LABELS`: `["private-9f95fd05bbfc-automation"]` for isolated metadata jobs.

Each scale set registers against this repository and uses `minRunners: 0`:
a queued job creates a temporary worker, results and post steps complete, and
ARC deletes the worker. The controller/listener remain available. These
Terraform variables do not install or register runners. Qualify every pool
before applying the self-hosted route. An existing `CI_RUNNER_GENERAL_LABELS`
override must be removed or explicitly set to the qualified CI pool, otherwise
it takes precedence in the long-running RuView validation job.

To switch to GitHub-hosted compute, prepare a complete saved plan in this root
with `-var='ci_runner_mode=github'`, review it, and apply those saved bytes. To
switch back, repeat with `-var='ci_runner_mode=self-hosted'`. Set the same value
in the workspace inputs used by subsequent runs; a one-time command-line
variable does not change the workspace's future defaults. Keep the pool labels
unchanged in hosted mode. Start a new workflow after the change; an already
queued job is not moved automatically. The public Terraform repository's own
workflows remain on GitHub-hosted runners.

This migration updates only the three existing label-variable instances.
`CI_RUNNER_MODE` remains self-hosted unless explicitly overridden. Repository
identity, visibility, review permissions and hosted updater policy are unchanged.
Review the complete plan and investigate unrelated drift rather than masking it
with `-target`. Keep plans and state outside source control. After activation,
run the consumer's manual `runner-smoke.yml`, verify its artifact, exercise
native ARM64 and metadata jobs separately, and confirm worker pods return to zero.

Static registrations and persistent worker Deployments are retired. Do not
restore their old label arrays, registration PVCs, bootstrap tokens or replicas.
The consumer's shared metadata workflows are materialized locally from immutable
toolkit sources, preserving caller-owner execution.

## Independent review automation

Workflow tokens default to read-only access. The separate approval permission
allows the shared reviewer's GitHub Actions fallback for supported bot authors;
human-authored PRs still require the independent review credential. Enabling
this permission grants neither repository-content write access nor a ruleset
bypass. Keep review credentials in GitHub Actions secrets, outside Terraform
source, variables and state.

The metadata route must point to a separately qualified repository-scoped
runner. Never reuse either build pool. Callers use trusted default-branch
metadata events, never check out PR code, and fail closed if this route is
absent. Qualify the isolated listener before applying this route. Temporary
local build overrides are operational settings and are not owned by this map.

The existing workflow permissions and read-only workflow default are preserved.
GitHub currently returns `allow_auto_merge=false` for this private repository
even after an explicit enable request, so this root retains that supported value.
The shared reviewed merger checks current approval and the explicit CI gate;
an immediate merge from `gh pr merge --auto` does not prove that GitHub retained
the native auto-merge setting.

Repository destruction is guarded by `prevent_destroy` while its resource block
remains present. That safeguard is not a substitute for reviewing configuration
removal. Source publication and application deployment are separate operations.

From the repository root, `bash scripts/ci.sh` validates the configured roots
without backend access. Keep the complete resource inventory and deployment
receipts with the operator's protected configuration, outside public documentation.
