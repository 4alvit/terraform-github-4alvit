# Infrastructure ownership

The canonical HCP Terraform workspace
`alvit-infrastructure/github-4alvit-infrastructure` owns adopted personal-account
GitHub resources. Organization workspaces own their respective organization
resources; the personal repositories containing their Terraform code belong to
the personal-account configuration.

## Separate roots

Each independent repository root must remain the sole state owner of the remote
objects listed in its configuration. Do not add them to the top-level root,
import them into another workspace or use an empty state to work around access
failures. An HTTP 404 from HCP can mean missing access or a missing workspace;
verify authenticated identity and access before initializing any backend.

The public exception is [victron-venus/inverter-climate](https://github.com/victron-venus/inverter-climate).
Its [independent stack](../stacks/inverter-climate-repository/README.md) owns the
repository-level security, Actions permissions and branch rules in workspace
`victron-venus/github-inverter-climate-repository`. Do not also add those objects
to the personal or organization state. Any ownership change needs a coordinated
state handoff and a protected rollback copy.

An empty plan covers resources represented in that state. It does not establish
that excluded objects or API-inaccessible protections have no drift. Keep the
complete authorized inventory and operational evidence outside public docs.

## Existing Actions variables

`unmanaged-integrations.tf` adopts `ENDPOINT_ID` and `PORTAINER_URL` for the
configured repository. Before importing, copy the exact existing GitHub values
through authenticated API clients into these sensitive Terraform-category inputs,
with HCL parsing disabled:

- `portainer_actions_endpoint_id` receives `ENDPOINT_ID`.
- `portainer_actions_url` receives `PORTAINER_URL`.

The inputs have no defaults. Do not use placeholders, commit values or log API
payloads. Import must preserve the existing bytes. Reconcile a proposed value
update before applying. Sensitive inputs redact ordinary output but remain in
protected Terraform state; the GitHub objects remain Actions variables.

## Existing webhook

`github_repository_webhook.portainer_push` adopts the configured existing hook,
preserving its active `push` subscription, JSON payloads and TLS certificate
verification. Supply its exact endpoint through `portainer_push_webhook_url` and
its existing receiver HMAC through `portainer_push_webhook_secret` in canonical
HCP state. Use the `github.webhook` provider alias with the separate sensitive
`github_webhook_token` input and the necessary repository Webhooks permission.

GitHub's [webhook configuration API](https://docs.github.com/en/rest/repos/webhooks#get-a-webhook-configuration-for-a-repository)
returns a secret mask, which cannot be used as an import credential. Read the
original secret from the authorized receiver configuration and transfer it
directly into the sensitive input without printing or committing it. Confirm
receiver identity and live configuration against the operator's deployment record.

This workspace owns the GitHub webhook object; receiver deployment has a
separate owner. Deliberate credential rotation must update both sides together.
Do not assume a stale deployment input reflects a secret changed through the
receiver UI. Import must not rotate credentials, deploy the receiver or use
`ignore_changes` to hide missing inputs.

## Exclusions and verification

The disabled legacy release webhook is recorded in the
[legacy webhook manifest](../activation/legacy-release-webhooks.json). Preserve
its endpoint, secret and disabled state without recreating or enabling it.
An exclusion is not a claim of Terraform coverage.

Objects outside the adopted inventory retain their existing state and visibility.
An API permission failure leaves a protection unverified; it does not prove the
protection absent. Do not change visibility, purchase a plan or delete resources
to turn an access error into a successful check.

After an approved infrastructure change, compare the full live inventory and
run an unrestricted plan. Preserve existing resource identities and require
no unintended changes before completing the handoff. Keep credentials, saved
plans, state backups and operational inventories outside source control.
