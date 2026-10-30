# Cisco CI and review protection

`cisco-review-policy.tf` adds one ruleset for the existing public
`4alvit/cisco-home-telephony` repository. Its canonical state owner is
`alvit-infrastructure/github-4alvit-infrastructure`. It does not create the
repository or change release or visibility settings. `automation-bot.tf` also
registers `californiantiramisu` with write (`push`) permission, required for its
approval to count. Existing collaborator resource addresses are unchanged.

The default branch requires one current approval, resolved review conversations
and strict success of `validate`, `images` and `Wake gate`, each bound to
GitHub Actions (App 15368). The declared owner retains the shared emergency
bypass for direct updates and history repair. Other actors, including the
automation account, remain subject to review, CI and history protection. A private, archived or different-owner target fails the
plan rather than silently dropping the protection.

## Activate in order

1. Merge and verify the Cisco workflows that emit `validate`, `images` and
   `Wake gate` on every pull request. Its scope job must distinguish irrelevant changes from failed
   detection; the final gate must reject a failed or skipped relevant build.
   Requiring the earlier path-filtered `build` job would block documentation-only
   pull requests indefinitely.
2. Confirm the live repository is public and active, and inspect existing
   rulesets. If this rule already exists, import its ID into the address below
   rather than creating a duplicate.
3. Inspect the bot's live collaborator role and any pending invitation. Public
   read access is not a collaborator grant. Import an existing grant only if it
   actually exists; do not import a missing relationship. In the existing
   canonical workspace, generate a fresh saved targeted plan:

   ```sh
   terraform plan \
     '-target=github_repository_collaborator.automation_bot["cisco-home-telephony"]' \
     -target=github_repository_ruleset.cisco_main -out=cisco-governance.tfplan
   ```

   When the bot already has write access, expect only an in-place ruleset
   update and necessary data reads. Accept a missing bot grant only when
   explicitly required; reject replacements, deletions and unrelated changes.
   Verify the shared approval workflow and its existing credential access
   before requiring approval. A collaborator grant alone cannot run reviews. The ruleset depends on this
   grant, but GitHub may create a pending invitation first. The saved plan may
   contain workspace secrets;
   keep it local, uncommitted and access restricted. Apply only the reviewed plan
   after the workflow prerequisite is green. A source/contract test is not a
   state-aware plan and does not prove live enforcement.
4. Accept only this repository's invitation using the existing bot identity, if
   GitHub created one. Verify its live role is `write` and no invitation remains;
   a successful Terraform apply alone does not establish that the bot can review.
   Never bypass the rule while waiting for acceptance.
5. Read the resulting live rule and check its owner, default branch, review count,
   declared owner bypass and all three exact required contexts. Run the normal unrestricted plan
   separately to distinguish this narrow activation from overall drift.

Rollback must preserve required review and working CI: if a check name changes,
first restore the always-emitted workflow or coordinate its replacement with the
ruleset. Do not delete the rule or invent a successful check to unblock a merge.

`bash scripts/test-cisco-governance.sh` tests the actual policy using a mocked
provider, including private/archived/wrong-owner rejection. It never reads state
or applies infrastructure.
