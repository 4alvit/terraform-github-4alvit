# Automatic deletion of merged branches

Every repository resource managed here enables GitHub's
`delete_branch_on_merge` setting. The shared `modules/github_repo` module uses
`true` by default, rejects `false`, and treats a `null` input as the enabled
default. Both root module callers also set `true` explicitly. The independent
repository stacks set the same property directly.

Run the focused regression check with:

```bash
python3 scripts/test-branch-cleanup.py
```

It discovers repository resource declarations and tests the production HCL
using mocked Terraform plans in temporary directories. It covers public and
private module inputs, explicit enablement, null input, rejection of disabled
cleanup, and every standalone repository stack. It uses no GitHub credentials,
remote state, or live resource operations. A new resource scope needs an
isolated fixture before this check can pass.

## Existing repositories and state ownership

This policy covers resources, not every repository referenced by a data source,
collaborator grant, or branch ruleset. In particular,
`cisco-review-policy.tf` reads `4alvit/cisco-home-telephony` as a data source and
manages its governance without owning the repository's general settings.
Changing that file's rules cannot enable merged-branch cleanup on Cisco.

Reconcile live repository settings separately where metadata is not owned by
this state. The scoped
[`scripts/reconcile-branch-cleanup.py`](../scripts/reconcile-branch-cleanup.py)
utility audits the authenticated user's repositories and organizations where
that user has active administrator membership. It applies only the cleanup flag
when explicitly requested:

```bash
# Audit all authorized owners; no settings are changed.
python3 scripts/reconcile-branch-cleanup.py

# Audit one authorized owner and write a private receipt.
python3 scripts/reconcile-branch-cleanup.py --owner 4alvit --output ~/.local/state/github-branch-cleanup/4alvit-audit.json

# Enable cleanup and verify it for all authorized owners.
python3 scripts/reconcile-branch-cleanup.py --apply
```

Repeat `--owner` to limit the scope to several authorized owners. By default,
receipts go to `~/.local/state/github-branch-cleanup/TIMESTAMP.json` with mode
`0600`. The utility reports repositories it cannot change, preserves archived
state, and returns a nonzero exit status when reconciliation remains incomplete.
It neither deletes existing branches directly nor grants additional permissions.

Before adopting any such repository into Terraform, identify its
existing state owner, import the existing object into exactly one canonical
state, and review the complete metadata plan. Do not create a duplicate
repository resource merely to change this one setting.

The setting applies to merged pull-request head branches eligible for deletion.
It does not remove local branches or worktrees, and it is separate from the
`allow_auto_merge` setting that controls how a pull request is merged.
