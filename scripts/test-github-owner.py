#!/usr/bin/env python3
"""Exercise the locked GitHub provider against a credential-free loopback fixture."""

# Preserve the operator-facing CLI filename used by scripts/ci.sh.
# pylint: disable=invalid-name
import json
import os
import re
import shutil
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STACKS = (
    ROOT / "stacks/oci-alvit-repository",
    ROOT / "stacks/claude-harness-repository",
    ROOT / "stacks/ruview-home-sensing-repository",
)
OWNER = "4alvit"
PROVIDERS = """terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    }
  }
}
"""


class FakeGitHub(BaseHTTPRequestHandler):
    """Only answer the reads needed to configure the provider and look up a user."""

    def do_GET(self):  # pylint: disable=invalid-name
        self.server.request_paths.append(self.path)
        route = self.path.removeprefix("/api/v3")
        if route.startswith("/orgs/"):
            status, body = 404, {"message": "Not Found"}
        elif route == "/user":
            status, body = 200, {"login": OWNER, "id": 123, "type": "User"}
        elif route in (f"/users/{OWNER}/gpg_keys", f"/users/{OWNER}/keys"):
            status, body = 200, []
        else:
            status, body = 500, {"message": "Unexpected fixture request"}
        content = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def log_message(self, *_args):
        """Keep request credentials and provider noise out of test output."""


def provider_block(stack):
    """Use the deployment's real owner settings, without its backend/resources."""
    source = (stack / "main.tf").read_text(encoding="utf-8")
    matches = re.findall(r'^provider "github" \{\n([^{}]*)^\}', source, re.MULTILINE)
    if len(matches) != 1:
        raise ValueError("Expected one simple GitHub provider block")
    body = matches[0]
    for line in body.splitlines():
        if (
            line.strip()
            and not line.lstrip().startswith("#")
            and not re.fullmatch(
                r'\s*(owner|organization)\s*=\s*"[A-Za-z0-9-]+"\s*', line
            )
        ):
            raise ValueError("Review fixture isolation after provider settings change")
    return body


def run_terraform(directory, environment, *arguments):
    """No inherited arguments, backend, state, real token or remote API target."""
    result = subprocess.run(
        ["terraform", f"-chdir={directory}", *arguments],
        env=environment,
        capture_output=True,
        text=True,
        timeout=180,
        check=False,
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)


def check_owner(directory, environment, server, body, conflicting, expected):
    """A data-only local plan forces actual ConfigureContextFunc execution."""
    port = server.server_address[1]
    fixture = f"""{PROVIDERS}
provider "github" {{
{body}
  base_url = "http://127.0.0.1:{port}/"
}}
data "github_user" "authenticated" {{ username = "" }}
output "fixture_user" {{ value = data.github_user.authenticated.login }}
"""
    (directory / "main.tf").write_text(fixture, encoding="utf-8")
    server.request_paths.clear()
    run_terraform(
        directory,
        {**environment, **conflicting},
        "plan",
        "-refresh=false",
        "-input=false",
        "-lock=false",
        "-no-color",
    )
    owners = [
        path.removeprefix("/api/v3/orgs/")
        for path in server.request_paths
        if path.startswith("/api/v3/orgs/")
    ]
    if not owners or set(owners) != {expected}:
        raise AssertionError(
            f"Effective owner mismatch: expected {expected}, saw {owners}"
        )


def main():
    """Test hostile inherited owner values and a failing original-code control."""
    bodies = [(stack, provider_block(stack)) for stack in STACKS]
    lock = (STACKS[0] / ".terraform.lock.hcl").read_bytes()
    if any((stack / ".terraform.lock.hcl").read_bytes() != lock for stack in STACKS):
        raise ValueError("Owner fixtures require identical provider locks")
    with tempfile.TemporaryDirectory(prefix="github-owner-contract-") as temporary:
        directory = Path(temporary)
        (directory / "empty.tfrc").write_text("", encoding="utf-8")
        (directory / "provider-cache").mkdir()
        shutil.copyfile(
            STACKS[0] / ".terraform.lock.hcl", directory / ".terraform.lock.hcl"
        )
        environment = {
            "PATH": os.environ["PATH"],
            "HOME": str(directory),
            "TF_IN_AUTOMATION": "1",
            "TF_INPUT": "0",
            "TF_CLI_CONFIG_FILE": str(directory / "empty.tfrc"),
            "TF_PLUGIN_CACHE_DIR": str(directory / "provider-cache"),
            "GITHUB_TOKEN": "synthetic-loopback-fixture-token",
        }
        with ThreadingHTTPServer(("127.0.0.1", 0), FakeGitHub) as server:
            server.request_paths = []
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            try:
                # Init only downloads the locked provider; it cannot contact a backend.
                (directory / "main.tf").write_text(
                    PROVIDERS,
                    encoding="utf-8",
                )
                run_terraform(
                    directory,
                    environment,
                    "init",
                    "-backend=false",
                    "-input=false",
                    "-lockfile=readonly",
                    "-no-color",
                )
                conflicts = [
                    {},
                    {"GITHUB_OWNER": "wrong-owner"},
                    {"GITHUB_ORGANIZATION": "wrong-organization"},
                    {
                        "GITHUB_OWNER": "wrong-owner",
                        "GITHUB_ORGANIZATION": "wrong-organization",
                    },
                ]
                for stack, body in bodies:
                    for inherited in conflicts:
                        check_owner(directory, environment, server, body, inherited, OWNER)
                    # Verify real v6 precedence, not a fixture that ignores owner settings.
                    old_body = re.sub(
                        r"^\s*organization\s*=.*\n", "", body, flags=re.MULTILINE
                    )
                    check_owner(
                        directory,
                        environment,
                        server,
                        old_body,
                        conflicts[-1],
                        "wrong-organization",
                    )
                    print(f"Owner contract passed: {stack.relative_to(ROOT)}")
            finally:
                server.shutdown()
                thread.join()
    print(
        "GitHub owner contracts passed: four environment cases and a negative control per stack."
    )


if __name__ == "__main__":
    main()
