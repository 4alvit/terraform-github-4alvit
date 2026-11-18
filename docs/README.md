# Documentation

Terraform for the **4alvit** personal GitHub account: repository settings, branch
rulesets, release standards and the CI policy that validates this source.

## Workspace and ownership

- [Select the canonical HCP account](hcp-account-selection.md) — the `alvit-infrastructure/github-4alvit-infrastructure` workspace, its immutable account ID and the named `4alvit` credential profile.
- [Infrastructure ownership](infrastructure-ownership.md) — which workspace owns adopted personal-account resources and which belong to organization workspaces.

## Repository and branch governance

- [Public iOS product repositories](ios-products.md) — the three application repositories declared in `ios-products.tf`.
- [Travel document CI requirements](travel-ci-governance.md) — the required checks a pull request against `travel-documents-ios` must pass.
- [Cisco CI and review protection](cisco-ci-governance.md) — the single ruleset added for the public `cisco-home-telephony` repository.
- [EPG main branch governance](EPG_BRANCH_PROTECTION.md) — the EPG ruleset owned by this state, with the repository kept as a data source.
- [Speed Dial branch governance](speeddial-governance.md) — adoption of the existing `speeddial` ruleset without creating a second policy.
- [Automatic deletion of merged branches](merged-branch-cleanup.md) — the `delete_branch_on_merge` default in the shared repository module.

## Release standards

- [Optional GitHub governance](release-governance.md) — the additive `release-standards.tf` opt-in, its empty defaults and the activation file.
- [Room release activation](room-release-activation.md) — the three managed objects added for `room-inventory-ios`.
- [Public software security policy](public-security.md) — the owner bypass policy, its actor and how it interacts with the shared admin merge actor.

## Validation toolchain

- [FLOSS source-validation profile](OPENTOFU.md) — the OpenTofu 1.13.1, GitHub provider 6.13.0 and TFLint toolchain used to validate this source.
- [OpenTofu profile advisory assessment — 2026-10-16](OPENTOFU_ADVISORIES.md) — the advisory findings for that OpenTofu build and which operations the assessment covers.
- [Disclosed secure-provider profile](SECURE_PROVIDER.md) — the patched-provider option and why the official 6.13.0 binary keeps its findings.
- [Local-execution TLS transport profile](TLS_PROFILE.md) — the transport key policy for the maintained Terraform configurations and provider calls.

## CI and evidence

- [CI and release operations](release-workflow.md) — `.release-policy.json`, the `CI gate` status and how workflow and lockfile changes are validated.
- [CI and release policy](CI_WORKFLOW.md) — the events the Quality gate covers and what counts as a passing validation run.
- [CI orchestration](CI-ORCHESTRATION.md) — how pull-request, merge-queue, default-branch and nightly events are assigned to the gate and release pipeline.
- [Quality evidence and limitations](quality.md) — what the MIT-licensed source and its Python/shell tooling do and do not establish.
- [OpenSSF evidence](openssf-evidence.md) — the source index for reviewing the current badge assessment.
