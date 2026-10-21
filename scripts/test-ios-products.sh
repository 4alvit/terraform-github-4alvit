#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
temporary=$(mktemp -d "${TMPDIR:-/tmp}/ios-products-test.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/tests" "$temporary/modules" "$temporary/provider-cache"
touch "$temporary/empty.tfrc"
cp ios-products.tf providers.tf "$temporary/"
cp -R modules/github_repo "$temporary/modules/"
cp tests/ios-products.tftest.hcl "$temporary/tests/"
if [[ -f .terraform.lock.hcl ]]; then
  cp .terraform.lock.hcl "$temporary/"
fi

# Only mock plan tests in an isolated source fixture. No remote state or tokens.
test_terraform() {
  env -i PATH="$PATH" HOME="$temporary" TF_IN_AUTOMATION=1 TF_INPUT=0 \
    TF_CLI_CONFIG_FILE="$temporary/empty.tfrc" TF_PLUGIN_CACHE_DIR="$temporary/provider-cache" \
    terraform -chdir="$temporary" "$@"
}
test_terraform init -backend=false -input=false -no-color
test_terraform test -no-color
