#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/validate-source.py
python3 scripts/validate-terraform.py
bash scripts/test-release-governance.sh
python3 scripts/test-github-owner.py
python3 scripts/test-branch-cleanup.py
bash scripts/test-public-security.sh
bash scripts/test-cisco-governance.sh
bash scripts/test-epg-governance.sh
bash scripts/test-ios-products.sh
bash scripts/test-runner-routing.sh
bash scripts/test-climate-governance.sh
tflint --config="$PWD/.tflint.hcl" --recursive
