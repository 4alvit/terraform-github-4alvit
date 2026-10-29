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


def repository_resources(source):
    """Find top-level resource headers, excluding HCL comments and templates."""
    length = len(source)

    def comment_end(index):
        if source.startswith("/*", index):
            end = source.find("*/", index + 2)
            if end < 0:
                raise ValueError("Unterminated HCL block comment")
            return end + 2
        end = source.find("\n", index)
        return length if end < 0 else end

    def heredoc_end(index):
        header = re.match(r"<<-?([^\s]+)[ \t]*\r?\n", source[index:])
        if not header:
            raise ValueError("Invalid HCL heredoc header")
        marker = re.escape(header.group(1))
        start = index + header.end()
        end = re.search(
            r"^[ \t]*" + marker + r"[ \t]*\r?$", source[start:], re.MULTILINE
        )
        if not end:
            raise ValueError("Unterminated HCL heredoc")
        return start + end.end()

    def string_end(index):
        index += 1
        while index < length:
            if source[index] == "\\":
                index += 2
            elif source.startswith(("$${", "%%{"), index):
                index += 3
            elif source.startswith(("${", "%{"), index):
                index = interpolation_end(index + 2)
            elif source[index] == '"':
                return index + 1
            else:
                index += 1
        raise ValueError("Unterminated HCL quoted string")

    def interpolation_end(index):
        depth = 1
        while index < length:
            if source.startswith(("/*", "//", "#"), index):
                index = comment_end(index)
            elif source.startswith("<<", index):
                index = heredoc_end(index)
            elif source[index] == '"':
                index = string_end(index)
            else:
                depth += (source[index] == "{") - (source[index] == "}")
                index += 1
                if depth == 0:
                    return index
        raise ValueError("Unterminated HCL template interpolation")

    tokens = []
    index = 0
    while index < length:
        if source[index].isspace():
            index += 1
        elif source.startswith(("/*", "//", "#"), index):
            index = comment_end(index)
        elif source.startswith("<<", index):
            index = heredoc_end(index)
        elif source[index] == '"':
            end = string_end(index)
            try:
                label = json.loads(source[index:end])
            except json.JSONDecodeError:
                label = None  # Templates are expressions, not resource labels.
            tokens.append(("string", label))
            index = end
        else:
            identifier = re.match(r"[\w-]+", source[index:])
            if identifier:
                tokens.append(("identifier", identifier.group()))
                index += identifier.end()
            else:
                tokens.append((source[index], source[index]))
                index += 1

    resources = []
    depth = 0
    for index, token in enumerate(tokens):
        if depth == 0 and token == ("identifier", "resource"):
            header = tokens[index + 1 : index + 4]
            if (
                len(header) == 3
                and header[0] == ("string", "github_repository")
                and header[1][0] == "string"
                and isinstance(header[1][1], str)
                and header[2][0] == "{"
            ):
                resources.append(header[1][1])
        depth += (token[0] == "{") - (token[0] == "}")
    return resources


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
        resources = repository_resources(source.read_text())
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
    # Keep engine-specific mock syntax in HCL so check_opentofu.py adapts it
    # alongside the other fixtures, without changing these policy assertions.
    provider = (ROOT / "tests/fixtures/branch-cleanup-provider.tftest.hcl").read_text()
    return (
        provider
        + f"""
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
    )


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
            # Init must record the current platform's package hash in this
            # disposable lock. Read-only locks can verify the downloaded ZIP
            # yet leave terraform test unable to verify its extracted cache.
            # No -upgrade: the repository's selected provider version stays pinned.
            for command in (
                [
                    "init",
                    "-backend=false",
                    "-input=false",
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
