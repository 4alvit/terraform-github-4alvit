# Speed Dial branch governance

The canonical personal-account state adopts only the existing
`4alvit/speeddial` ruleset `25988957`, named **Public main review and CI**.
The declarative import in `imports.tf` uses
`speeddial:25988957`; it does not create a second policy or import the repository.

The API baseline verified on 2026-10-29 targets exactly `refs/heads/main`, with
no exclusions. It requires one approval, dismisses stale approvals, requires
resolved review conversations, and accepts merge, squash and rebase. Code-owner
review and approval of the last push remain disabled. The existing deletion and
non-fast-forward protections remain enabled. **Application checks** remains the
only required status check, with strict checking and no integration restriction.

The sole intended policy change is the existing `User` actor `272257197`
(`4alvit`): its bypass mode changes from `pull_request` to `always` through the
shared owner setting. No repository role or automation actor gains bypass.
Version-tag policies and release controls are outside this resource.

Before applying, save the full response from
`GET /repos/4alvit/speeddial/rulesets/25988957` and compare the plan against it.
After applying, compare the same endpoint again: only the owner's bypass mode
may change among policy fields. Ignore server metadata such as `updated_at` and
the computed `current_user_can_bypass` field when comparing.

Provider `integrations/github` 6.13.0 represents an unrestricted status-check
integration with `0`; GitHub may omit that field in its API response. The API
baseline also has empty `required_reviewers` and
`require_extra_approval_for_unattributed_changes: false`. The provider supports
the former (no reviewer blocks preserves the empty list), but does not expose
the latter. Verify that the latter stays false after applying, and preserve
any newer API-only fields if GitHub adds them. Retain the saved complete policy
response for that comparison rather than reconstructing it from Terraform state.

Run `bash scripts/test-speeddial-governance.sh` for isolated mock-provider plans
covering policy parity, owner-only bypass and rejection of private, archived or
wrong-owner targets. These plans make no authenticated GitHub changes.
