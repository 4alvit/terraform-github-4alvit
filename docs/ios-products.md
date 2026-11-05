# Public iOS product repositories

`ios-products.tf` declares three original applications in the canonical
`alvit-infrastructure/github-4alvit-infrastructure` workspace
(`ws-AKy7NQFpKuV5KHyr`):

- `4alvit/room-inventory-ios`: room inventory and portable document exports.
- `4alvit/document-sanitizer-ios`: document redaction and metadata cleanup.
- `4alvit/travel-documents-ios`: offline travel document organization.

This configuration is an onboarding declaration, not evidence of an applied
deployment or an App Store release. Do not create separate states for these
objects or import objects owned elsewhere.

## Apply and verify

Verify the HCP token identity and canonical workspace access using the procedure
in the root README. A 404 is not permission to create or select another workspace.
Check the canonical state and live repository inventory before creation; if any
repository already exists, reconcile its owner and import only into its sole
owning state. Review a full saved plan and apply only the expected additions.
Stop for unrelated changes. Do not apply an isolated empty-state plan.

Each repository is public, seeded with an MIT license, and uses `main` as its
default branch. The declaration enables secret scanning and push protection,
vulnerability alerts and read-only default workflow tokens. Dependabot security-update
PRs are explicitly disabled in favor of Renovate. Actions may submit approvals under explicitly granted job permissions.
The existing approved automation account receives Write access; verify its
accepted access before relying on it as reviewer.

Default-branch rules require a pull request, one approval, fresh reviews after a
push, last-push approval, resolved threads, signed commits, and prevent branch
deletion or force pushes for ordinary contributors. The declared account owner
has permanent branch bypass; other administrators and automation receive no
additional exception.
Version tags matching `v*` cannot be updated or deleted, including prereleases.
Use a new version number when fixing a published prerelease.

The `document-sanitizer-ios` default-branch policy additionally requires its
established acceptance jobs and source analyses against the current base. The
six GitHub Actions checks (app ID `15368`) are `macOS core, independent export
corpus, iOS build`, `Russian iPad privacy at system AX5`, `Native StoreKit
eight-case acceptance`, `Exact packaged Release share smoke`, `analyze / CodeQL
Analysis`, and `Swift security analysis`. The aggregate `CodeQL` result is bound
to the CodeQL app (`57789`). These checks do not grant a merge bypass, and a
successful analysis alone does not replace native acceptance. The other two
iOS repository policies retain their existing check requirements.

Before applying this addition, verify all seven exact check names and app IDs
on the current Sanitizer PR, including a successful Swift analysis and all four
native acceptance jobs. Review a full saved plan showing only the Sanitizer
default-branch ruleset update. No repository creation, collaborator change,
application deployment, or other ruleset change belongs in this operation.

After apply, follow `docs/public-security.md` to reconcile the unsupported extra
Copilot approval flag while preserving every other rule. Verify private
vulnerability reporting separately using GitHub's repository API, since the
pinned provider does not expose that setting. Inspect live settings and run a
full unrestricted plan to detect unintended drift. Keep state, plans, backups,
credential material and operational evidence outside version control.

## First application push

1. Fetch the remote `main` seed before pushing application code. Base the first
   application branch on that commit and preserve the MIT license; do not
   overwrite the seed with a force push or unrelated history.
2. Commit with the approved signing identity, push a feature branch, and open a
   PR to `main`. The branch rules apply from repository creation.
3. Install SHA-pinned workflows. Native iOS build/test jobs require an appropriate
   GitHub-hosted macOS runner and real available simulator destination. The Linux
   self-hosted runner convention used by some account repositories does not build
   an iOS app. Keep fixtures, screenshots and test documents synthetic.
4. Publish green checks on the actual application revision. Only after the
   workflows land and their names are verified, opt each repository into the
   additive release `CI gate` protection and any applicable release environments.
   CodeQL or other required checks must not be installed before their workflows.
5. Check independent reviews, CI and release evidence before creating an honest
   GitHub prerelease. App Store signing, agreements and publication remain
   separate from GitHub repository provisioning.

Repository creation does not install application workflows or validate native
iOS code. These remain the responsibility of the three product owners.
