#!/usr/bin/env python3
"""Audit or enable merged-branch cleanup without adopting repository metadata."""

import argparse
import datetime as dt
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import HTTPRedirectHandler, Request, build_opener


class APIError(Exception):
    """A diagnostic containing no API response body or credentials."""


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


class GitHub:
    """Use gh's authenticated reads and refuse redirects on writes."""

    def __init__(self):
        self.login = None
        self._token = None

    @staticmethod
    def _gh(args):
        result = subprocess.run(
            ["gh", *args], capture_output=True, text=True, check=False
        )
        if result.returncode:
            raise APIError("gh_request_failed")
        return result.stdout

    def get(self, endpoint):
        try:
            value = json.loads(
                self._gh(
                    ["api", "--hostname", "github.com", "--method", "GET", endpoint]
                )
            )
        except json.JSONDecodeError as exc:
            raise APIError("invalid_api_json") from exc
        if not isinstance(value, dict):
            raise APIError("invalid_api_object")
        return value

    def pages(self, endpoint):
        try:
            pages = json.loads(
                self._gh(
                    [
                        "api",
                        "--hostname",
                        "github.com",
                        "--method",
                        "GET",
                        "--paginate",
                        "--slurp",
                        endpoint,
                    ]
                )
            )
        except json.JSONDecodeError as exc:
            raise APIError("invalid_api_json") from exc
        if not isinstance(pages, list) or any(not isinstance(p, list) for p in pages):
            raise APIError("invalid_api_pages")
        rows = [row for page in pages for row in page]
        if any(not isinstance(row, dict) for row in rows):
            raise APIError("invalid_api_rows")
        return rows

    def _http(self, endpoint, method="GET", body=None, token=None):
        credential = self._token if token is None else token
        if not credential:
            raise APIError("missing_write_credential")
        request = Request(
            "https://api.github.com/" + endpoint,
            data=json.dumps(body).encode() if body is not None else None,
            method=method,
            headers={
                "Authorization": "Bearer " + credential,
                "Accept": "application/vnd.github+json",
                "Content-Type": "application/json",
                "X-GitHub-Api-Version": "2022-11-28",
                "User-Agent": "github-branch-cleanup",
            },
        )
        try:
            with build_opener(NoRedirect()).open(request, timeout=30) as response:
                value = json.load(response)
                if not isinstance(value, dict):
                    raise APIError("invalid_api_object")
                return value
        except HTTPError as exc:
            reason = "redirect_refused" if 300 <= exc.code < 400 else f"http_{exc.code}"
            raise APIError(reason) from None
        except (URLError, TimeoutError, json.JSONDecodeError) as exc:
            raise APIError("request_outcome_unknown") from exc

    def patch(self, endpoint, body):
        if body != {"delete_branch_on_merge": True}:
            raise APIError("unsupported_mutation")
        if self._token is None:
            candidate = (
                os.environ.get("GH_TOKEN")
                or os.environ.get("GITHUB_TOKEN")
                or self._gh(["auth", "token", "--hostname", "github.com"]).strip()
            )
            if (
                not candidate
                or self._http("user", token=candidate).get("login", "").lower()
                != self.login
            ):
                raise APIError("write_identity_mismatch")
            self._token = candidate
        return self._http(endpoint, method="PATCH", body=body)


def save_receipt(path, receipt):
    """Replace each incremental receipt atomically, always with mode 0600."""
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    descriptor, temporary = tempfile.mkstemp(prefix=".branch-cleanup-", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            os.fchmod(stream.fileno(), 0o600)
            json.dump(receipt, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def matches(repo, expected):
    return (
        repo.get("id") == expected["id"]
        and repo.get("full_name", "").lower() == expected["full_name"].lower()
        and repo.get("owner", {}).get("login", "").lower() == expected["owner"]
    )


def reconcile(api, receipt, save):
    login = api.get("user")["login"].lower()
    api.login = login
    memberships = api.pages("user/memberships/orgs?state=active&per_page=100")
    allowed = {login} | {
        row["organization"]["login"].lower()
        for row in memberships
        if row.get("state") == "active" and row.get("role") == "admin"
    }
    owners = sorted({owner.lower() for owner in receipt["requested_owners"]} or allowed)
    if any(owner not in allowed for owner in owners):
        raise APIError("owner_not_authorized")
    receipt.update(authenticated_login=login, owners=owners)
    seen = set()
    for owner in owners:
        endpoint = (
            "user/repos?affiliation=owner&visibility=all&per_page=100"
            if owner == login
            else f"orgs/{quote(owner, safe='')}/repos?type=all&per_page=100"
        )
        for repo in api.pages(endpoint):
            full_name = repo.get("full_name", "")
            actual_owner = repo.get("owner", {}).get("login", "").lower()
            if actual_owner != owner or full_name.partition("/")[0].lower() != owner:
                raise APIError("inventory_owner_mismatch")
            if not isinstance(repo.get("id"), int) or not full_name.partition("/")[2]:
                raise APIError("invalid_repository_identity")
            if repo["id"] in seen:
                continue
            seen.add(repo["id"])
            receipt["repositories"].append(
                {
                    "id": repo["id"],
                    "full_name": full_name,
                    "owner": owner,
                    "status": "pending",
                    "final_value": None,
                }
            )
        save()

    for row in receipt["repositories"]:
        endpoint = "repos/" + "/".join(
            quote(part, safe="") for part in row["full_name"].split("/")
        )
        try:
            fresh = api.get(endpoint)
            if not matches(fresh, row):
                raise APIError("repository_identity_changed")
            value = fresh.get("delete_branch_on_merge")
            value = value if isinstance(value, bool) else None
            row.update(
                before_value=value,
                final_value=value,
                archived=fresh.get("archived"),
                disabled=fresh.get("disabled"),
                admin=fresh.get("permissions", {}).get("admin"),
            )
            if value is True:
                row["status"] = "already_enabled"
            elif value is None:
                row["status"] = "skipped_unknown_setting"
            elif fresh.get("disabled") is not False:
                row["status"] = "skipped_disabled_or_unknown"
            elif fresh.get("permissions", {}).get("admin") is not True:
                row["status"] = "skipped_no_admin"
            elif not receipt["apply"]:
                row["status"] = "would_enable"
            else:
                row.update(status="patch_pending", final_value=None)
                save()
                api.patch(endpoint, {"delete_branch_on_merge": True})
                row["status"] = "verification_pending"
                save()
                verified = api.get(endpoint)
                if not matches(verified, row):
                    raise APIError("verification_identity_changed")
                value = verified.get("delete_branch_on_merge")
                row["final_value"] = value if isinstance(value, bool) else None
                row["status"] = "enabled" if value is True else "verification_failed"
        except APIError as exc:
            row.update(
                status="refused_or_unverified", reason=str(exc), final_value=None
            )
        save()


def main(argv=None, api=None, stdout=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--owner",
        action="append",
        default=[],
        help="Repeat for selected authorized owners; default: all.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Enable only delete_branch_on_merge; default is audit.",
    )
    default = (
        Path.home()
        / ".local/state/github-branch-cleanup"
        / (dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ") + ".json")
    )
    parser.add_argument(
        "--output", type=Path, default=default, help="Private incremental JSON receipt."
    )
    args = parser.parse_args(argv)
    path = args.output.expanduser().absolute()
    receipt = {
        "started_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "apply": args.apply,
        "requested_owners": args.owner,
        "status": "running",
        "repositories": [],
    }

    def save():
        save_receipt(path, receipt)

    save()
    try:
        reconcile(api or GitHub(), receipt, save)
        receipt["status"] = "complete"
        code = int(
            any(row["final_value"] is not True for row in receipt["repositories"])
        )
    except (APIError, OSError, KeyError, TypeError) as exc:
        receipt.update(
            status="incomplete",
            error=str(exc) if isinstance(exc, APIError) else type(exc).__name__,
        )
        code = 2
    receipt["finished_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
    receipt["exit_code"] = code
    save()
    rows = receipt["repositories"]
    print(
        json.dumps(
            {
                "mode": "apply" if args.apply else "audit",
                "status": receipt["status"],
                "repositories": len(rows),
                "enabled": sum(r["final_value"] is True for r in rows),
                "remaining_false": sum(r["final_value"] is False for r in rows),
                "unknown": sum(r["final_value"] is None for r in rows),
                "receipt": str(path),
            }
        ),
        file=stdout or sys.stdout,
    )
    return code


if __name__ == "__main__":
    sys.exit(main())
