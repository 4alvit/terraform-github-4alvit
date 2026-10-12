#!/usr/bin/env python3
"""Reconcile review counts and GitHub's extra Copilot approval after Terraform.

Defaults to inspection. --apply changes only approval counts above one and
require_extra_approval_for_unattributed_changes. Other rule fields are preserved.
Authentication comes from the GitHub CLI; no credentials are printed or saved.
"""

import argparse
import copy
import json
import os
import subprocess
from pathlib import Path


def api(path, method="GET", body=None, paginate=False):
    """Call GitHub through the operator's existing CLI authentication."""
    command = ["gh", "api", "--method", method, path]
    if paginate:
        command.extend(["--paginate", "--slurp"])
    if body is not None:
        command.extend(["--input", "-"])
    result = subprocess.run(
        command,
        input=None if body is None else json.dumps(body),
        capture_output=True,
        text=True,
        check=False,
        env={**os.environ, "GODEBUG": "http2client=0"},
    )
    if result.returncode:
        if method == "GET" and "Upgrade to GitHub" in result.stderr:
            return None
        raise RuntimeError(f"GitHub {method} {path}: {result.stderr.strip()}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def writable(rule):
    """Keep every writable ruleset field, including all unrelated protections."""
    keys = ("name", "target", "enforcement", "bypass_actors", "conditions", "rules")
    return {key: rule[key] for key in keys if key in rule}


def main():
    """Inspect an explicitly selected owner and apply reviewed changes on request."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--owner", required=True,
                        choices=("4alvit", "victron-venus", "ha-homelab", "open-ott-play"))
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--backup-dir", type=Path,
                        help="Required with --apply; stores original ruleset bodies locally")
    args = parser.parse_args()
    if args.apply and args.backup_dir is None:
        parser.error("--apply requires --backup-dir")
    if args.backup_dir:
        args.backup_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    pages = api("user/repos?affiliation=owner,organization_member&per_page=100", paginate=True)
    repositories = [repo for page in pages for repo in page
                    if repo["owner"]["login"] == args.owner]
    endpoints = set()
    unavailable = []
    archived = []
    for repo in repositories:
        name = repo["full_name"]
        if repo["archived"]:
            archived.append(name)
            continue
        pages = api(f"repos/{name}/rulesets?includes_parents=true&per_page=100", paginate=True)
        if pages is None:
            unavailable.append(name)
            continue
        for page in pages:
            for rule in page:
                prefix = {"Repository": "repos", "Organization": "orgs"}.get(rule["source_type"])
                if prefix is None:
                    raise RuntimeError("Unsupported inherited ruleset source")
                endpoints.add(f"{prefix}/{rule['source']}/rulesets/{rule['id']}")
    changes = []
    for endpoint in sorted(endpoints):
        original = api(endpoint)
        before = writable(original)
        after = copy.deepcopy(before)
        for rule in after["rules"]:
            if rule["type"] == "pull_request":
                parameters = rule["parameters"]
                if parameters.get("required_approving_review_count", 0) > 1:
                    parameters["required_approving_review_count"] = 1
                parameters["require_extra_approval_for_unattributed_changes"] = False
        if before == after:
            continue
        if args.apply:
            backup = args.backup_dir / f"ruleset-{original['id']}.json"
            with backup.open("x", encoding="utf-8") as stream:
                os.chmod(backup, 0o600)
                json.dump(original, stream, indent=2)
            if writable(api(endpoint)) != before:
                raise RuntimeError("Ruleset changed during review: " + endpoint)
            api(endpoint, method="PUT", body=after)
            if writable(api(endpoint)) != after:
                raise RuntimeError("Ruleset verification failed: " + endpoint)
        changes.append(endpoint)
    print(json.dumps({"owner": args.owner, "applied": args.apply,
                      "changed_rulesets": changes, "feature_unavailable": unavailable,
                      "archived_read_only": archived}, indent=2))


if __name__ == "__main__":
    main()
