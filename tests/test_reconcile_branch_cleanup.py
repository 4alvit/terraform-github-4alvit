"""Offline tests for the deliberately narrow GitHub operations helper."""

import copy
import importlib.util
import io
import json
import os
import stat
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, call, patch
from urllib.error import HTTPError

SOURCE = Path(__file__).resolve().parents[1] / "scripts/reconcile-branch-cleanup.py"
SPEC = importlib.util.spec_from_file_location("branch_cleanup", SOURCE)
cleanup = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cleanup)


def repository(enabled=False, owner="alice", **changes):
    value = {
        "id": 1,
        "full_name": owner + "/example",
        "owner": {"login": owner},
        "delete_branch_on_merge": enabled,
        "permissions": {"admin": True},
        "archived": False,
        "disabled": False,
    }
    value.update(changes)
    return value


class FakeGitHub:
    def __init__(self, repo=None, fresh=None, after=True, error=None):
        self.repo = repo or repository()
        self.fresh = copy.deepcopy(fresh if fresh is not None else self.repo)
        self.after = after
        self.error = error
        self.calls = []
        self.patches = []
        self.before_patch = None
        self.memberships = [
            {"state": "active", "role": "admin", "organization": {"login": "team"}}
        ]

    def get(self, endpoint):
        self.calls.append(("GET", endpoint))
        if endpoint == "user":
            return {"login": "alice"}
        return copy.deepcopy(self.fresh)

    def pages(self, endpoint):
        self.calls.append(("PAGES", endpoint))
        if endpoint.startswith("user/memberships/"):
            return self.memberships
        return [copy.deepcopy(self.repo)]

    def patch(self, endpoint, body):
        self.calls.append(("PATCH", endpoint))
        self.patches.append((endpoint, copy.deepcopy(body)))
        if self.before_patch:
            self.before_patch()
        if self.error:
            raise cleanup.APIError(self.error)
        self.fresh["delete_branch_on_merge"] = self.after
        return copy.deepcopy(self.fresh)


class ReconcileTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.output = Path(self.temporary.name) / "receipt.json"

    def invoke(self, api, *arguments):
        stdout = io.StringIO()
        code = cleanup.main(
            ["--owner", "alice", "--output", str(self.output), *arguments],
            api=api,
            stdout=stdout,
        )
        self.summary = json.loads(stdout.getvalue())
        self.receipt = json.loads(self.output.read_text())
        return code

    def test_default_dry_run_never_writes_github(self):
        api = FakeGitHub()
        self.assertEqual(self.invoke(api), 1)
        self.assertEqual(api.patches, [])
        self.assertEqual(self.receipt["repositories"][0]["status"], "would_enable")
        self.assertNotIn("example", json.dumps(self.summary))
        self.assertIn(
            ("PAGES", "user/repos?affiliation=owner&visibility=all&per_page=100"),
            api.calls,
        )

    def test_apply_changes_only_exact_field_and_journals_before_write(self):
        api = FakeGitHub()

        def check_journal():
            row = json.loads(self.output.read_text())["repositories"][0]
            self.assertEqual(row["status"], "patch_pending")
            self.assertIsNone(row["final_value"])

        api.before_patch = check_journal
        self.assertEqual(self.invoke(api, "--apply"), 0)
        self.assertEqual(
            api.patches, [("repos/alice/example", {"delete_branch_on_merge": True})]
        )
        self.assertEqual(
            api.calls[-3:],
            [
                ("GET", "repos/alice/example"),
                ("PATCH", "repos/alice/example"),
                ("GET", "repos/alice/example"),
            ],
        )

    def test_rejects_owner_outside_authenticated_scope(self):
        api = FakeGitHub()
        self.assertEqual(self.invoke(api, "--owner", "outsider", "--apply"), 2)
        self.assertEqual(api.patches, [])
        self.assertEqual(self.receipt["error"], "owner_not_authorized")

    def test_non_admin_or_inactive_membership_does_not_authorize_owner(self):
        for role, state in [("member", "active"), ("admin", "pending")]:
            with self.subTest(role=role, state=state):
                api = FakeGitHub()
                api.memberships[0].update(role=role, state=state)
                self.assertEqual(self.invoke(api, "--owner", "team", "--apply"), 2)
                self.assertEqual(api.patches, [])

    def test_enabled_unknown_no_admin_and_disabled_are_not_patched(self):
        cases = [
            (repository(True), "already_enabled", 0),
            (repository(None), "skipped_unknown_setting", 1),
            (repository("false"), "skipped_unknown_setting", 1),
            (repository(permissions={"admin": False}), "skipped_no_admin", 1),
            (repository(disabled=True), "skipped_disabled_or_unknown", 1),
        ]
        for repo, status, code in cases:
            with self.subTest(status=status):
                api = FakeGitHub(repo)
                self.assertEqual(self.invoke(api, "--apply"), code)
                self.assertEqual(api.patches, [])
                self.assertEqual(self.receipt["repositories"][0]["status"], status)

    def test_fresh_get_overrides_stale_inventory(self):
        api = FakeGitHub(repository(False), fresh=repository(True))
        self.assertEqual(self.invoke(api, "--apply"), 0)
        self.assertEqual(api.patches, [])

    def test_redirect_transfer_rename_and_identity_change_refused(self):
        for fresh in [
            repository(owner="outsider"),
            repository(full_name="alice/renamed"),
            repository(id=2),
        ]:
            with self.subTest(fresh=fresh):
                api = FakeGitHub(fresh=fresh)
                self.assertEqual(self.invoke(api, "--apply"), 1)
                self.assertEqual(api.patches, [])
                self.assertEqual(
                    self.receipt["repositories"][0]["reason"],
                    "repository_identity_changed",
                )

    def test_success_response_with_false_readback_is_failure(self):
        api = FakeGitHub(after=False)
        self.assertEqual(self.invoke(api, "--apply"), 1)
        self.assertEqual(len(api.patches), 1)
        self.assertEqual(
            self.receipt["repositories"][0]["status"], "verification_failed"
        )

    def test_archived_refusal_never_retries_or_unarchives(self):
        api = FakeGitHub(repository(archived=True), error="http_403")
        self.assertEqual(self.invoke(api, "--apply"), 1)
        self.assertEqual(
            api.patches, [("repos/alice/example", {"delete_branch_on_merge": True})]
        )
        self.assertTrue(api.fresh["archived"])
        self.assertEqual(self.receipt["repositories"][0]["reason"], "http_403")

    def test_private_receipt_replaces_insecure_existing_file_atomically(self):
        self.output.write_text("old receipt")
        self.output.chmod(0o666)
        self.assertEqual(self.invoke(FakeGitHub(repository(True))), 0)
        self.assertEqual(stat.S_IMODE(self.output.stat().st_mode), 0o600)
        self.assertEqual(list(self.output.parent.glob(".branch-cleanup-*")), [])

    def test_transport_refuses_write_redirect(self):
        api = cleanup.GitHub()
        api._token = "test-credential"
        opener = Mock()
        opener.open.side_effect = HTTPError(
            "https://api.github.com/repos/alice/example", 301, "Moved", {}, None
        )
        with (
            patch.object(cleanup, "build_opener", return_value=opener),
            self.assertRaisesRegex(cleanup.APIError, "redirect_refused"),
        ):
            api.patch("repos/alice/example", {"delete_branch_on_merge": True})
        self.assertEqual(opener.open.call_count, 1)
        request = opener.open.call_args.args[0]
        self.assertEqual(request.method, "PATCH")
        self.assertEqual(json.loads(request.data), {"delete_branch_on_merge": True})
        self.assertIsNone(
            cleanup.NoRedirect().redirect_request(
                None, None, 301, "Moved", {}, "https://example.com"
            )
        )

    def test_write_credential_must_match_read_identity(self):
        api = cleanup.GitHub()
        api.login = "alice"
        with (
            patch.dict(os.environ, {"GH_TOKEN": "test-credential"}),
            patch.object(api, "_http", return_value={"login": "bob"}) as http,
            self.assertRaisesRegex(cleanup.APIError, "write_identity_mismatch"),
        ):
            api.patch("repos/alice/example", {"delete_branch_on_merge": True})
        http.assert_called_once_with("user", token="test-credential")
        self.assertIsNone(api._token)

    def test_failed_identity_request_does_not_authorize_next_repository(self):
        api = cleanup.GitHub()
        api.login = "alice"
        with (
            patch.dict(os.environ, {"GH_TOKEN": "test-credential"}),
            patch.object(
                api,
                "_http",
                side_effect=[
                    cleanup.APIError("request_outcome_unknown"),
                    {"login": "alice"},
                    {"delete_branch_on_merge": True},
                ],
            ) as http,
        ):
            with self.assertRaisesRegex(cleanup.APIError, "request_outcome_unknown"):
                api.patch("repos/alice/first", {"delete_branch_on_merge": True})
            self.assertIsNone(api._token)
            api.patch("repos/alice/second", {"delete_branch_on_merge": True})
        self.assertEqual(
            http.call_args_list,
            [
                call("user", token="test-credential"),
                call("user", token="test-credential"),
                call(
                    "repos/alice/second",
                    method="PATCH",
                    body={"delete_branch_on_merge": True},
                ),
            ],
        )

    def test_malformed_transport_shapes_are_rejected(self):
        api = cleanup.GitHub()
        with (
            patch.object(api, "_gh", return_value="[]"),
            self.assertRaisesRegex(cleanup.APIError, "invalid_api_object"),
        ):
            api.get("user")
        with (
            patch.object(api, "_gh", return_value='[["not-a-repo"]]'),
            self.assertRaisesRegex(cleanup.APIError, "invalid_api_rows"),
        ):
            api.pages("user/repos")


if __name__ == "__main__":
    unittest.main()
