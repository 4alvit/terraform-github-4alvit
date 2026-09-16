# Infrastructure ownership

This configuration and the canonical HCP Terraform workspace
`alvit-infrastructure/github-4alvit-infrastructure` own adopted resources under
the `4alvit` account.
The organization workspaces own their respective organization resources; the
personal repositories containing that Terraform code still belong here.
An empty plan covers resources represented in this state. It does not establish
that excluded objects or API-inaccessible protections have no drift.

## Existing Portainer Actions variables

`unmanaged-integrations.tf` adopts `ENDPOINT_ID` and `PORTAINER_URL` from
`4alvit/terraform-portainer-synology`. Before the import plan, copy their exact
existing GitHub values through the authenticated GitHub/HCP API clients into
these **sensitive Terraform-category workspace inputs**, with HCL parsing off:

- `portainer_actions_endpoint_id` receives `ENDPOINT_ID`.
- `portainer_actions_url` receives `PORTAINER_URL`.

The inputs deliberately have no defaults. Do not use placeholders, commit values,
or log API payloads. Import must preserve the existing values byte-for-byte; a
plan proposing a value update needs reconciliation before apply. Sensitive input
marking redacts normal CLI output; the values remain part of the protected
Terraform state. The existing GitHub objects remain Actions variables.

## Active webhook and original HMAC source

`github_repository_webhook.portainer_push` adopts the existing
`terraform-portainer-synology` hook `675888988`, retaining its active `push`
subscription, JSON payloads and certificate verification. Supply the exact GitHub
endpoint as sensitive input `portainer_push_webhook_url` and the existing receiver
HMAC as `portainer_push_webhook_secret` in this canonical HCP workspace.
The webhook uses the `github.webhook` provider alias with the sensitive
`github_webhook_token` input: the repository-management credential cannot read
this private webhook. The supplied existing credential must have repository
Webhooks read/write permission (or classic `admin:repo_hook`); it is not stored
in source. Other resources continue using their existing provider credential.
GitHub's
[webhook configuration API](https://docs.github.com/en/rest/repos/webhooks#get-a-webhook-configuration-for-a-repository)
returns a secret mask; that mask is not a valid import credential.

The receiver is Portainer stack `28`, `github-deploy-webhook`. Its deployment
belongs to HCP workspace `victron-venus/portainer-github-deploy-webhook`, whose
`portainer_stack.this` environment maps `WEBHOOK_SECRET` from `webhook_secret`.
The 2026-09-13 adoption verified that the exact workspace's state serial `4` and
a read-only live stack request contained the same nonempty secret. The existing
secret and GitHub endpoint were transferred directly into sensitive inputs,
without printing values, writing them into source, or changing the receiver.

The live receiver credential is the original shared-secret source. This workspace
holds the matching protected input for the GitHub registration and is the sole
Terraform owner of that webhook object. A future deliberate credential rotation
must update the receiver's source and matching GitHub input together. The receiver
stack currently excludes environment changes from reconciliation, so do not
assume a stale deployment input reflects a secret changed in the Portainer UI.
Recheck the live receiver when reconciling credentials. Import must not rotate a
secret, deploy a stack, or use `ignore_changes` to hide missing webhook inputs.

## Retired webhook exclusion

`solar-forecast-langgraph` hook `675885248` remains outside Terraform state as a
retired, inactive `ping`/`release` subscription. Its disabled operational policy
is recorded in [the legacy webhook manifest](../activation/legacy-release-webhooks.json).
Preserve its endpoint, secret and disabled state without recreating or enabling
it. This explicit exclusion is not a claim of Terraform coverage for that hook.

## Temporary repositories and visibility limits

`tmp-runner-test` and `tmp-runner-test2` remain intentionally outside this state.
Both are private, have reported size zero, and have not been pushed since their
creation on 2026-08-26. They are classified as temporary from that metadata and
their names; no repository content was read. Preserve them without deleting,
archiving, changing visibility, or adding access. Reassess the exclusion if they
receive persistent work.

Ruleset and classic branch-protection requests returned HTTP 403 for all eleven
private repositories in the 25-repository account inventory. Those protections
are **unverified**, not proven absent. The fourteen public repositories had no
separate classic default-branch protection; their rulesets were inventoried.
No plan upgrade or paid protection is introduced to remove this visibility limit.
