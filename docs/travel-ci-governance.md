# Travel document CI requirements

The `ios_products_default["travel-documents-ios"]` ruleset requires successful
checks on the current base before an ordinary pull request can merge:

- `CI gate`, from GitHub Actions (integration `15368`). It always runs and
  requires the core/purchase, guidance, both iPad locales, and recovery groups
  to succeed. A skipped, cancelled, or failed group does not satisfy the gate.
- `analyze / CodeQL Analysis` and `Swift security analysis`, from GitHub Actions
  (integration `15368`).
- `CodeQL`, from the CodeQL application (integration `57789`).

The CI and CodeQL workflows run for all pull requests, merge groups, and pushes
to `main`, without path filters. Python/Actions analysis uses the shared
workflow with `force-full: true`; Swift analysis is unconditional. Documentation
changes therefore also produce the required results. If workflow names,
conditions, or application identities change, update this policy in the same
coordinated rollout after verifying the replacement checks.

The existing one-review policy, dismissal of stale reviews, last-push approval,
resolved discussions, signed commits, and history protection stay in force.
The owner's previously configured emergency exception is unchanged. Sanitizer
keeps its existing exact check set; Room is not opted into Travel's check names.

## Apply and verify

First verify all four context/application pairs on the current Travel pull
request, then merge the source analysis workflow and verify its default-branch
results. The current ruleset does not enable a merge queue. If one is introduced
later, enable it in a controlled validation window, enqueue a reviewed pull
request, and verify all four results on the resulting `merge_group` run before
relying on the queue for ordinary merges. Configured triggers alone are not
evidence of an executed queue check; see the [GitHub event documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#merge_group).
Follow the [canonical HCP account checks](hcp-account-selection.md)
before using the existing workspace. Review a saved plan restricted to
`github_repository_ruleset.ios_products_default["travel-documents-ios"]`.
It must only add the four required checks and strict base policy to that
existing ruleset; do not include release activation, credential changes,
other repositories, or unrelated drift.

After applying the exact reviewed plan, read back the complete ruleset and
confirm all four context/application pairs and the preserved review controls.
Follow the existing [review-policy reconciliation procedure](public-security.md)
if the provider drops a separately managed review option. Check the targeted
resource again for no further changes, and inspect a fresh unrestricted plan
to report unrelated drift separately. A successful local mock test validates
configuration shape; it does not prove that live rules or CI were applied.
