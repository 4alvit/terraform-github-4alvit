# Select the canonical HCP account

This repository owns `alvit-infrastructure/github-4alvit-infrastructure`,
workspace ID `ws-AKy7NQFpKuV5KHyr`. Use the existing named `4alvit` profile at
`~/.config/terraform/accounts/4alvit.json`. Its expected immutable HCP account ID
is `user-dEj6Gd4JyYuMeNeR`; the username observed on 2026-11-02 was `4alvit`.
The profile label and username alone are not identity checks.

The default Terraform credential authenticated as the distinct account `alvit`
and returned 404 for this workspace. The named profile returned 200 for the
expected account and workspace. Do not retry with default credentials, select
another organization, create a workspace or detach the existing backend to
work around a 401, 403, 404 or identity mismatch. Browser sign-in does not select
the credential used by Terraform.

The existing local launcher `~/.local/bin/terraform-4alvit` selects this named
profile, checks its file permissions and recorded expiry, and passes its token
only to the Terraform child. It does not perform the API identity checks below
or qualify the `terraform` executable selected from `PATH`. Do not treat the
launcher alone as a completed preflight, and do not use it for `victron-venus`
workspaces, which have a different account owner.

## Verify before initialization, plan or apply

Run from this repository's primary checkout. Keep the example read-only until
the exact operation and execution profile have been reviewed. It loads the
named profile into memory, verifies both API identities without following
redirects, and prints no token or raw response. It never changes the default
credential file or writes plaintext credentials.

```python
import json
import os
from pathlib import Path
import subprocess
import urllib.error
import urllib.request

command = None  # Read-only. Later, set only the reviewed absolute command argv.
profile = Path.home() / ".config/terraform/accounts/4alvit.json"
expected_account = "user-dEj6Gd4JyYuMeNeR"
expected_organization = "alvit-infrastructure"
expected_workspace = "ws-AKy7NQFpKuV5KHyr"
expected_name = "github-4alvit-infrastructure"

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None

opener = urllib.request.build_opener(NoRedirect)

def require(condition, message):
    if not condition:
        raise SystemExit(message)

try:
    selected = json.loads(profile.read_text())
    require(selected.get("account") == "4alvit", "Wrong named profile")
    token = selected["credentials"]["app.terraform.io"]["token"]
    require(isinstance(token, str) and bool(token), "Missing named credential")

    def read(path):
        request = urllib.request.Request(
            "https://app.terraform.io/api/v2/" + path,
            headers={"Authorization": "Bearer " + token,
                     "Content-Type": "application/vnd.api+json"},
        )
        with opener.open(request, timeout=20) as response:
            return json.load(response)["data"]

    account = read("account/details")
    require(account["id"] == expected_account, "Wrong HCP account; stop")
    workspace = read("workspaces/" + expected_workspace)
    attributes = workspace["attributes"]
    require(workspace["id"] == expected_workspace, "Wrong workspace; stop")
    require(attributes["name"] == expected_name, "Wrong workspace name; stop")
    require(workspace["relationships"]["organization"]["data"]["id"]
            == expected_organization, "Wrong workspace organization; stop")
except urllib.error.HTTPError as error:
    raise SystemExit("HCP preflight refused: HTTP " + str(error.code)) from None
except Exception:
    raise SystemExit("HCP preflight failed; inspect the private profile/access") from None

print("Verified named 4alvit account and canonical organization/workspace")
print("Execution mode:", attributes["execution-mode"])
print("Terraform version:", attributes["terraform-version"])
print("Locked:", attributes["locked"])

if command is not None:
    require(isinstance(command, list) and bool(command)
            and Path(command[0]).is_absolute(), "Use reviewed absolute argv")
    environment = dict(os.environ)
    environment["TF_TOKEN_app_terraform_io"] = token
    raise SystemExit(subprocess.run(command, env=environment, check=False).returncode)
```

Supply the verified credential as `TF_TOKEN_app_terraform_io` in the selected
child process, as shown above. Do not run a later bare `terraform plan` or
`terraform apply` that silently reverts to the default profile. Do not put token
values in shell arguments, history, logs, screenshots or repository files.
Keep any saved plan and state metadata private.

Before enabling `command`, also confirm the checkout's `cloud` configuration
and existing cached backend refer to this same canonical organization/workspace;
check current runs/locks and state ownership. Use the reviewed runtime/provider
and process settings. An identity check is not a plan review or apply approval.
It does not authorize changing execution mode, migrating state or replacing a
credential. Review the exact resulting plan before its separate apply.

On 2026-11-02 the workspace reported **remote execution, Terraform 1.15.7**.
Re-read these fields before operating. The local transport evidence in
[TLS_PROFILE.md](TLS_PROFILE.md) does not qualify a remote worker, and the patched
provider's independent local-state profile in
[SECURE_PROVIDER.md](SECURE_PROVIDER.md) does not deploy that provider to HCP.
Resolve the actual execution-profile requirements before the Room release plan;
do not infer readiness merely from successful authentication.
