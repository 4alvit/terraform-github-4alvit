#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
temporary=$(mktemp -d "${TMPDIR:-/tmp}/release-governance-test.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
test_root="$temporary/tests/release-governance"
mkdir -p "$test_root/tests" "$temporary/provider-cache" "$temporary/modules"
touch "$temporary/empty.tfrc"
cp admin-merge-policy.tf "$test_root/"
cp public-security.tf release-standards.tf ha-homelab.tf webhook-inputs.tf tests/release-governance/main.tf "$test_root/"
cp -R modules/github_repo "$temporary/modules/"
cp tests/release-governance.tftest.hcl "$test_root/tests/"
if [[ -f .terraform.lock.hcl ]]; then
  cp .terraform.lock.hcl "$test_root/"
fi

# The test copy has no cloud/backend configuration. Drop credentials and ambient
# Terraform arguments, and use mock-provider plan tests with no live API calls.
test_terraform() {
  env -i PATH="$PATH" HOME="$temporary" TF_IN_AUTOMATION=1 TF_INPUT=0 \
    TF_CLI_CONFIG_FILE="$temporary/empty.tfrc" TF_PLUGIN_CACHE_DIR="$temporary/provider-cache" \
    terraform -chdir="$test_root" "$@"
}
test_terraform init -backend=false -input=false -no-color
test_terraform test -no-color
