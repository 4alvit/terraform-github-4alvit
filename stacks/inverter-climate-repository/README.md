# Inverter Climate repository

This independent Terraform root owns the public
`victron-venus/inverter-climate` repository, vulnerability alerts, dependency
update settings, Actions token permissions, branch/release rules, the protected
release environment, and the release publication variables. The owner explicitly requested this source repository as its Terraform
home. It does not adopt or move any existing personal or organization resources.

Its sole state owner is
[victron-venus/github-inverter-climate-repository](https://app.terraform.io/app/victron-venus/workspaces/github-inverter-climate-repository).
Workspace ID: `ws-vw7QUAEPDm9RmED6`. Initial deployment on 2026-10-03 Pacific
created all five resources, with no updates, deletions, or imports.
Use local execution with auto-apply disabled and existing HCP credentials.
The top-level backend and the organization infrastructure workspace remain
unchanged. Do not declare these resources in either of those roots.

Run Terraform from this directory with the existing private `GITHUB_TOKEN` in
the process environment. The authenticated login must be `4alvit`, with access to
`victron-venus`. Do not store tokens in source or Terraform variables. Clear
`GITHUB_OWNER` and `GITHUB_ORGANIZATION` because provider 6.x can use those values
instead of its configured owner. Also clear inherited `TF_CLI_ARGS*` overrides.

```bash
cd stacks/inverter-climate-repository
terraform init
terraform plan -out=/private/path/inverter-climate.tfplan
terraform apply /private/path/inverter-climate.tfplan
terraform plan -detailed-exitcode
```

Inspect the complete saved plan before applying that exact plan. Initial
deployment must contain **5 creates, 0 changes, 0 destroys, and no imports**, only
for this repository. Keep plans and plan JSON outside source control in a private
directory. A subsequent full plan must report no changes. The repository has
`prevent_destroy` while its resource block remains present.

The repository is public with an MIT license, vulnerability alerts, read-only
default Actions tokens, and narrowly enabled Actions PR approval. Renovate owns
dependency updates through the shared organization preset and repository registry;
Dependabot security PR generation is disabled. The default branch requires the
shared `CI gate`, rejects deletion/force pushes, and requires resolved review
threads. Version tags are immutable. Stable release jobs require the owner
reviewing the `release` environment on `main`.

Apply these release settings only after the shared Quality gate workflow is
merged and green. `RELEASE_CHANNELS_ENABLED` enables verified release publication;
`SETUPHELPER_PUBLICATION_ENABLED` allows the separately verified publisher to
advance the artifact-only `latest` branch from stable release bytes. These
workflows do not deploy to the device.

From the source repository root, `bash scripts/ci.sh` validates all Terraform
roots in disposable copies without backend access.
