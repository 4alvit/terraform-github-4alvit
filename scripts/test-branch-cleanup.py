#!/usr/bin/env python3
"""Verify merged-branch cleanup with isolated, credential-free mock plans."""

# Preserve the documented operator-facing CLI filename.
# pylint: disable=invalid-name
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = Path("modules/github_repo")


def repository_scopes():
    """Discover every source repository resource, including independent stacks."""
    names = (
        subprocess.check_output(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
            cwd=ROOT,
        )
        .decode()
        .split("\0")
    )
    policy = json.loads((ROOT / ".release-policy.json").read_text())
    supported = {Path(name) for name in policy["terraform_roots"]} | {MODULE}
    scopes = {}
    for name in sorted(set(names)):
        source = ROOT / name
        if source.suffix != ".tf" or not source.is_file() or source.is_symlink():
            continue
        resources = re.findall(
            r'^\s*resource\s+"github_repository"\s+"([\w-]+)"\s*\{',
            source.read_text(),
            flags=re.MULTILINE,
        )
        if not resources:
            continue
        scope = Path(name).parent
        if scope not in supported or scope == Path("."):
            raise ValueError(f"Add an isolated branch-cleanup fixture for {name}")
        scopes.setdefault(scope, []).extend(resources)
    if MODULE not in scopes:
        raise ValueError("The shared repository module must be covered")
    return scopes


def stack_tests(scope, resources):
    """Assert the actual resource fields; no API response can substitute them."""
    inputs = ""
    if scope == Path("stacks/private-repository-01"):
        inputs = """variables {
  private_repository = {
    name = "private-cleanup-fixture"
    description = "Disposable mock-plan fixture"
    topics = ["fixture"]
  }
}
"""
    conditions = ",\n      ".join(
        f"github_repository.{name}.delete_branch_on_merge" for name in resources
    )
    return f"""mock_provider "github" {{
  override_during = plan
  mock_data "github_user" {{
    defaults = {{ login = "4alvit", id = "123" }}
  }}
}}
{inputs}
run "every_repository_enables_cleanup" {{
  command = plan
  assert {{
    condition = alltrue([
      {conditions}
    ])
    error_message = "Every repository must delete merged pull-request branches."
  }}
}}
"""


def main():
    """Use production HCL, mock providers, no backend, and no inherited secrets."""
    scopes = repository_scopes()
    with tempfile.TemporaryDirectory(prefix="branch-cleanup-test-") as temporary:
        base = Path(temporary)
        config = base / "empty.tfrc"
        config.write_text("")
        cache = base / "provider-cache"
        cache.mkdir()
        environment = {
            "PATH": os.environ["PATH"],
            "HOME": str(base),
            "TF_IN_AUTOMATION": "1",
            "TF_INPUT": "0",
            "CHECKPOINT_DISABLE": "1",
            "TF_CLI_CONFIG_FILE": str(config),
            "TF_PLUGIN_CACHE_DIR": str(cache),
        }
        for index, (scope, resources) in enumerate(sorted(scopes.items())):
            stage = base / f"scope-{index}"
            (stage / "tests").mkdir(parents=True)
            for source in (ROOT / scope).glob("*.tf"):
                if source.is_symlink():
                    raise ValueError("Fixture source must not be a symlink")
                shutil.copyfile(source, stage / source.name)
            lock = ROOT / scope / ".terraform.lock.hcl"
            shutil.copyfile(
                lock if lock.is_file() else ROOT / ".terraform.lock.hcl",
                stage / ".terraform.lock.hcl",
            )
            test = stage / "tests/branch-cleanup.tftest.hcl"
            if scope == MODULE:
                shutil.copyfile(ROOT / "tests/branch-cleanup-module.tftest.hcl", test)
            else:
                test.write_text(stack_tests(scope, resources))
            for command in (
                [
                    "init",
                    "-backend=false",
                    "-input=false",
                    "-lockfile=readonly",
                    "-no-color",
                ],
                ["test", "-no-color"],
            ):
                subprocess.run(
                    ["terraform", f"-chdir={stage}", *command],
                    env=environment,
                    check=True,
                    timeout=180,
                )
            print(f"Merged-branch cleanup passed: {scope}", flush=True)
    print(f"Covered {sum(map(len, scopes.values()))} repository resource declarations.")


if __name__ == "__main__":
    main()
