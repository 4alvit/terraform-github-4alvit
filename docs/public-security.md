# Public software security policy

`public-security.tf` lists the public repositories reviewed for this rollout.
Live metadata excludes private and archived repositories from new protections.
The required review count is one approval from a reviewer with Write access.
Automation may provide that approval. Keep this count at one when reconciling
Terraform with GitHub. Other committed proposals, including changes to bypass
actors and new review rules, require explicit selection through
`public_security_enforcement_repositories`, which is empty by default.
Existing checks, signatures and immutable-tag protections remain separate
requirements.

Secret scanning and push protection are enabled on the audited public repository
resources managed by this state. Private vulnerability reporting was enabled
separately through GitHub's repository API; the pinned Terraform provider does
not expose that setting. Verify it under repository security settings during
onboarding. Do not put a credential in a commit to test push protection.

## Retired HACS submission fork

`4alvit/default` is retired from the active public-software inventory and the
`automation_bot` collaborator set. The DESLOC integration and card submissions
are merged in the official HACS catalog ([integration #11471](https://github.com/hacs/default/pull/11471),
[card #11473](https://github.com/hacs/default/pull/11473)). Their releases and
updates come from `ha-homelab/ha-desloc` and `ha-homelab/ha-desloc-card`; the
submission fork is not a distribution dependency.

Close the fork's remaining maintenance PRs and preserve its Git refs before
archiving it. Review and apply this inventory cleanup in the canonical workspace
while the fork is still writable: it removes the fork's managed automation-bot
grant and any managed `public_review` instance, without deleting the repository
or changing active projects. Then archive `4alvit/default` through GitHub and
verify the archive state and absence of active automation. The repository itself
is not managed by this Terraform configuration. Keep the archive and its unique
commits for history; deleting the fork is not part of this retirement.

A stale `public_security_enforcement_repositories` value cannot reintroduce the
fork because it is no longer eligible for metadata lookup or enforcement.
To resume development later, explicitly unarchive the fork and restore only the
reviewed inventory entries and collaborator grant through a new plan.

## Rollout and state ownership

The selected incremental change enables `dismiss_stale_reviews_on_push` on
existing default-branch pull-request rules with a single required
approval, preserving bypass actors, Code Owners and CI/scanning requirements. It
creates no rulesets and imports no resources. This source change also covers
`github_repository_ruleset.default["4alvit"]`, whose previous source would
otherwise restore stale-approval dismissal to `false`.

GitHub separately rejected the profile repository's Gitar Bot bypass because the
app is not part of that ruleset's source or owner. The profile source therefore
excludes only that confirmed invalid app exception; its administrator bypass and
one-review requirement remain unchanged. This source correction does not itself
apply the live repair. A separate guarded update must verify the exact current
body and its own recorded rejection before removing that app exception. It does
not authorize removing valid or unverified app exceptions in other repositories.

Routine reconciliation preserves existing administrator exceptions and does not
activate new review rules. Select repositories in
`public_security_enforcement_repositories` only after verifying their reviewers
and approval workflows. Selection does not change the required count above one.
Existing enforced reviews remain active even when the selection is empty.
Inspect a full plan against the canonical existing state before any apply; use
the reviewed saved plan. Do not apply from empty or unrelated state.
For each selected setting update, compare the complete current ruleset with its
reviewed baseline, save the previous body and read back the result. Complete
active code PRs before enabling the new dismissal requirement for their
repository.

Check that the existing permitted reviewers can satisfy the chosen policy;
automation approvals do not establish independent human security review. A
higher review count is not selected merely to maximize a score. Any future new
ruleset must preserve existing protections and use its actual remote identity
when imported into the owning state.

## Extra Copilot approval after Terraform

GitHub's `require_extra_approval_for_unattributed_changes` setting must be
`false`: otherwise an unattributed Copilot PR needs an extra approval even when
the configured count is one. The pinned GitHub provider does not expose this
field, and sending a ruleset without it restores GitHub's default `true`.

After a ruleset apply or creation, run the shared
[review-policy reconciliation script](https://github.com/4alvit/terraform-github-4alvit/blob/main/scripts/reconcile-review-policy.py)
with `--owner OWNER` to inspect that owner's rules. Use `--apply --backup-dir DIR`
to save the current bodies, change only review counts above one and the extra
approval flag, and verify that all other protections remain intact. Choose a new
local backup directory for each application. Rules without required approvals
keep their zero count; archived repositories stay read-only and are reported.
This step is required until the provider supports the
extra-approval field; a Terraform plan alone cannot validate it.

## Trust boundaries

Terraform credentials can change repository governance; store them in the
canonical workspace's secret variables with the narrow required scope. Source
reviews must consider changed repository sets, ruleset bypasses, workflow token
permissions, release gates and remote object ownership. Validation runs use no
production state or credentials. Provider schemas and mock tests establish
configuration behavior, not the correctness of a future live apply.

## OpenSSF evidence and remaining assessment

Public Git history, the MIT license, README interfaces, contribution policy,
private reporting instructions and executable mock tests provide auditable
inputs for an OpenSSF Best Practices assessment. The new tests cover current
review requirements and exclusion of private/archived repositories. Required
CI results and actual live settings must be checked after merge.

No OpenSSF award is claimed by this document. Maintainer knowledge, external
report-response history, release-note applicability, full static-analysis scope
and all remaining mandatory criteria need individual verification. A repository
is not certified because its managed applications are certified or vice versa.
