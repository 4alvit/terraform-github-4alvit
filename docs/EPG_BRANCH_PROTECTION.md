# EPG main branch governance

The canonical personal GitHub state now owns the EPG ruleset. The repository
itself remains an existing data source; this change does not recreate it, change
visibility, start a deployment, or change workflow content.

The previous classic rule required one approval and a strict `python` check from
GitHub Actions (integration `15368`) on exact branch `main`. It blocked force
pushes and deletion. Stale-review dismissal, CODEOWNERS approval, last-push
approval, required signatures, and conversation resolution were disabled. The
replacement keeps those choices, with the common owner-only, pull-request-only
emergency exception from `admin-merge-policy.tf`.

## Safe adoption and migration

A read-only audit of all 35 accessible HCP workspaces and the local Terraform
sources found no existing owner of the classic EPG protection. Before migration,
repeat that ownership check and preserve the live rule and current state.

1. In this existing state, temporarily declare the exact old classic rule as
   `github_branch_protection_v3.epg_main_legacy`, with `enforce_admins=true`, and
   import `epg-voice-gateway:main`. Check that the imported rule matches the saved
   live settings. This adoption changes state only, not GitHub protection.
2. Remove the temporary declaration. Plan only
   `github_repository_ruleset.epg_main`, save and inspect the plan, and apply
   those bytes. It may create one replacement; it must not delete the old rule.
3. Read back the active replacement and verify all settings above, especially
   the GitHub Actions integration ID and the owner User ID `272257197` with
   `pull_request` bypass. Stop on any mismatch while the old protection remains.
4. Plan the obsolete `github_branch_protection_v3.epg_main_legacy` address. It may
   destroy only that classic rule. Apply the reviewed saved plan only after the
   replacement passes verification. Re-read the new rule, then run a full plan
   and treat unrelated drift separately.

If the replacement cannot be verified, keep the classic rule. For rollback after
migration, restore and verify the saved classic rule before removing the new
ruleset. Never remove both protections. Record any emergency merge reason and its
validation evidence in the pull request; ordinary bot merges continue to satisfy
all checks and reviews.
