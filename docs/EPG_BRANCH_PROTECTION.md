# EPG main branch governance

The canonical personal GitHub state owns the EPG ruleset. The repository itself
remains an existing data source; this does not recreate it, change visibility,
start a deployment, or change workflow content.

The previous classic rule required one approval and a strict `python` check from
GitHub Actions (integration `15368`) on exact branch `main`. It blocked force
pushes and deletion. Stale-review dismissal, CODEOWNERS approval, last-push
approval, required signatures, and conversation resolution were disabled. The
replacement keeps those choices, with the common owner-only, permanent branch
exception from `admin-merge-policy.tf`.

The migration completed on 2026-10-27. The replacement was verified while the
classic rule remained active; only then was the classic rule removed. The steps
below explain that migration for recovery, not a procedure to repeat on the
already migrated repository.

## Safe adoption and migration

A read-only audit of all 35 accessible HCP workspaces and the local Terraform
sources found no existing owner of the classic EPG protection. Before adopting a
similar object, repeat that ownership check and preserve its live settings and
the current state. Keep the original state lineage, workspace, and execution mode.

1. In a protected temporary directory, prepare an **import-only** configuration
   with this repository's existing HCP backend, the existing provider version,
   every provider alias referenced by state, and only the classic rule to adopt:
   `github_branch_protection.epg_main_legacy`, targeting the existing EPG
   repository and exact branch `main`. Configure providers from existing local
   credentials. Do not copy unrelated sensitive HCP variable values or invent
   placeholder secrets to make a full local configuration evaluate.
2. Initialize that temporary configuration against the existing workspace and
   verify its identity. Run only:

   ```sh
   terraform import github_branch_protection.epg_main_legacy epg-voice-gateway:main
   ```

   **Never run `terraform plan` or `terraform apply` from the partial temporary
   configuration.** The classic GraphQL resource above supports personal
   repositories. `github_branch_protection_v3` does not: provider 6.13 rejects it
   when the owner is a user. Import reads GitHub settings and adds state ownership;
   it does not rewrite the live rule or its GitHub Actions integration binding.
   Verify unchanged lineage, every pre-existing resource unchanged, and exactly
   one new legacy resource before proceeding.
3. Return to the **complete committed configuration** in this repository. Plan
   only `github_repository_ruleset.epg_main`, save and inspect the plan, and apply
   those bytes if the replacement does not already exist. It may create one
   replacement; it must not delete the old rule.
4. Read back the active replacement and verify every setting above, especially
   integration ID `15368`, the exact `main` scope, supported merge methods, and
   owner User ID `272257197` with `always` bypass. GitHub can default the
   provider-unsupported `require_extra_approval_for_unattributed_changes` flag to
   `true`; use the [existing review-policy reconciliation helper](../scripts/reconcile-review-policy.py)
   to set it to `false`, preserving all other fields. Stop on any mismatch while
   the old protection remains. Recheck this flag after later Terraform updates.
5. From the complete configuration, plan only the now-obsolete
   `github_branch_protection.epg_main_legacy` address. The saved plan may destroy
   only that classic rule. Apply it after the replacement passes verification.
   Verify the old classic endpoint returns 404 and the replacement still has
   exact expected protections. Run a full read-only plan and treat unrelated
   drift separately; do not apply it as part of this migration.
6. Keep protected state snapshots, reviewed plan hashes and readback receipts.
   Remove the temporary import configuration after successful verification so
   nobody accidentally treats it as a complete infrastructure root.

If the replacement cannot be verified, keep the classic rule. For rollback after
migration, restore and verify the saved classic rule before removing the new
ruleset. Never remove both protections. Record any emergency merge reason and its
validation evidence in the pull request; ordinary bot merges continue to satisfy
all checks and reviews.
