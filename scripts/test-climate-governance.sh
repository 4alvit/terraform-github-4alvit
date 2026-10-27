#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
temporary=$(mktemp -d "${TMPDIR:-/tmp}/climate-governance-test.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/tests" "$temporary/provider-cache"
touch "$temporary/empty.tfrc"
cp stacks/inverter-climate-repository/main.tf stacks/inverter-climate-repository/admin-merge-policy.tf "$temporary/"
cp stacks/inverter-climate-repository/.terraform.lock.hcl "$temporary/"
cp tests/climate-governance.tftest.hcl "$temporary/tests/"
# Mock-only plans, with production credentials and CLI configuration removed.
test_terraform() {
  env -i PATH="$PATH" HOME="$temporary" TF_IN_AUTOMATION=1 TF_INPUT=0 \
    TF_CLI_CONFIG_FILE="$temporary/empty.tfrc" TF_PLUGIN_CACHE_DIR="$temporary/provider-cache" \
    terraform -chdir="$temporary" "$@"
}
test_terraform init -backend=false -input=false -lockfile=readonly -no-color
test_terraform test -no-color
