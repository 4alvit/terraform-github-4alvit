# Cisco CI and review protection

`cisco-review-policy.tf` adds one ruleset for the existing public
`4alvit/cisco-home-telephony` repository. Its canonical state owner is
`alvit-infrastructure/github-4alvit-infrastructure`. It does not create the
repository or change release, collaborator or visibility settings.

The default branch requires one current approval, resolved review conversations
and strict success of `validate` and `Wake gate`, both bound to GitHub Actions
(App 15368). Administrators and automation have no bypass. Deletion and force
pushes are prohibited. A private, archived or different-owner target fails the
plan rather than silently dropping the protection.

## Activate in order

1. Merge and verify the Cisco workflow change that emits `Wake gate` on every
   pull request. Its scope job must distinguish irrelevant changes from failed
   detection; the final gate must reject a failed or skipped relevant build.
   Requiring the earlier path-filtered `build` job would block documentation-only
   pull requests indefinitely.
2. Confirm the live repository is public and active, and inspect existing
   rulesets. If this rule already exists, import its ID into the address below
   rather than creating a duplicate.
3. In the existing canonical workspace, generate a fresh saved targeted plan:

   ```sh
   terraform plan -target=github_repository_ruleset.cisco_main -out=cisco-governance.tfplan
   ```

   Accept only one new ruleset plus its repository data read: no replacements,
   deletions or unrelated changes. The saved plan may contain workspace secrets;
   keep it local, uncommitted and access restricted. Apply only the reviewed plan
   after the workflow prerequisite is green. A source/contract test is not a
   state-aware plan and does not prove live enforcement.
4. Read the resulting live rule and check its owner, default branch, review count,
   no-bypass policy and exact required contexts. Run the normal unrestricted plan
   separately to distinguish this narrow activation from overall drift.

Rollback must preserve required review and working CI: if a check name changes,
first restore the always-emitted workflow or coordinate its replacement with the
ruleset. Do not delete the rule or invent a successful check to unblock a merge.

`bash scripts/test-cisco-governance.sh` tests the actual policy using a mocked
provider, including private/archived/wrong-owner rejection. It never reads state
or applies infrastructure.
