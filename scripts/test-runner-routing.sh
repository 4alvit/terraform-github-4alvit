#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
temporary=$(mktemp -d "${TMPDIR:-/tmp}/runner-routing-test.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/tests" "$temporary/provider-cache"
touch "$temporary/empty.tfrc"
cp stacks/ruview-home-sensing-repository/main.tf "$temporary/main.tf"
cp tests/runner-routing/ruview.tftest.hcl "$temporary/tests/"
if [[ -f .terraform.lock.hcl ]]; then
  cp .terraform.lock.hcl "$temporary/"
fi
test_terraform() {
  env -i PATH="$PATH" HOME="$HOME" TF_IN_AUTOMATION=1 TF_INPUT=0 \
    TF_CLI_CONFIG_FILE="$temporary/empty.tfrc" TF_PLUGIN_CACHE_DIR="$temporary/provider-cache" \
    terraform -chdir="$temporary" "$@"
}
test_terraform init -backend=false -input=false -no-color
test_terraform test -no-color
