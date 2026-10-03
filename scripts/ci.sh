#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/validate-source.py
python3 scripts/validate-terraform.py
bash scripts/test-release-governance.sh
python3 scripts/test-github-owner.py
