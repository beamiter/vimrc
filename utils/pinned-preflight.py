#!/usr/bin/env python3
"""Verify exact Vim9 suite checkouts, optionally run the full smoke gate."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import tempfile


REGISTRY = Path(__file__).resolve().parents[1] / "config/plugins.vim"
DECLARATION = re.compile(
    r"simpleplug#Plug\('beamiter/(simple[a-z0-9]+)'"
    r"(?:, \{do: '\./install\.sh'\})?\)"
)
OID = re.compile(r"(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})")
SNAPSHOT_LIMIT = 65536


def declared_plugins():
    names = set()
    for line in REGISTRY.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("#") or "simpleplug#Plug" not in line:
            continue
        match = DECLARATION.fullmatch(line)
        if match is None or match[1] in names:
            raise ValueError("unsupported or duplicate declaration in config/plugins.vim")
        names.add(match[1])
    if not names:
        raise ValueError("no literal plugin declarations in config/plugins.vim")
    return names


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON key in snapshot")
        result[key] = value
    return result


def validate_origin(name, url):
    expected = f"https://github.com/beamiter/{name}"
    if url not in (expected, expected + ".git"):
        raise ValueError(f"{name}: unexpected origin; expected {expected}")


def read_pins(path, names):
    if path.is_symlink() or not path.is_file():
        raise ValueError("snapshot must be a regular file, not a symlink")
    with path.open("rb") as handle:
        payload = handle.read(SNAPSHOT_LIMIT + 1)
    if len(payload) > SNAPSHOT_LIMIT:
        raise ValueError("snapshot exceeds 64 KiB")
    data = json.loads(payload, object_pairs_hook=unique_object)
    if (not isinstance(data, dict) or set(data) != {"version", "plugins"}
            or type(data["version"]) is not int or data["version"] != 1
            or not isinstance(data["plugins"], dict)):
        raise ValueError("expected a SimplePlug PlugSnapshot v1 JSON file")
    pins = data["plugins"]
    if set(pins) != names:
        missing = ", ".join(sorted(names - set(pins))) or "none"
        raise ValueError(f"snapshot must match registry exactly (missing: {missing})")
    for name in sorted(names):
        entry = pins[name]
        if (not isinstance(entry, dict)
                or not {"commit", "url"} <= set(entry) <= {"commit", "url", "branch"}
                or not isinstance(entry["commit"], str) or not OID.fullmatch(entry["commit"])):
            raise ValueError(f"{name}: expected full commit and URL in v1 snapshot")
        validate_origin(name, entry["url"])
        # The supported declarations all have an implicit default branch. V1
        # omits branch in this case; do not interpret it as the checked out ref.
        if entry.get("branch", "") != "":
            raise ValueError(f"{name}: branch does not match the default registry declaration")
    return pins


def clean_home(home, names):
    home = home.absolute()
    if (home.is_symlink() or not home.is_dir() or home.stat().st_uid != os.getuid()
            or stat.S_IMODE(home.stat().st_mode) != 0o700):
        raise ValueError("PRIVATE_HOME must be a real, owned directory of mode 0700")
    # A later run may point HOME here without reading an existing .vimrc.local,
    # .vim/after, viminfo or package directory. Prepare daemon artifacts later.
    vimdir = home / ".vim"
    root = vimdir / "plugged"
    for parent, child in ((home, vimdir), (vimdir, root)):
        if child.is_symlink() or not child.is_dir():
            raise ValueError(f"expected real directory {child.name} in PRIVATE_HOME")
        if {entry.name for entry in parent.iterdir()} != {child.name}:
            raise ValueError("PRIVATE_HOME must contain only .vim/plugged")
    found = {entry.name for entry in root.iterdir()}
    if found != names:
        missing = ", ".join(sorted(names - found)) or "none"
        raise ValueError(f"checkout root must match registry exactly (missing: {missing})")
    return root.resolve()


def git(repo, env, *args):
    try:
        return subprocess.run(
            ["git", "-c", "core.fsmonitor=false", "-c", "core.untrackedCache=false",
             "-C", str(repo), *args],
            timeout=10, check=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
            env=env,
        ).stdout
    except (subprocess.SubprocessError, OSError) as exc:
        raise ValueError(f"{repo.name}: cannot verify checkout ({args[0]})") from exc


def verify_checkout(repo, pin, env):
    metadata = repo / ".git"
    if repo.is_symlink() or not repo.is_dir() or metadata.is_symlink() or not metadata.is_dir():
        raise ValueError(f"{repo.name}: expected a real checkout, not a symlink or nested checkout")
    # Plain, owned clones only. Do not let custom filters or included Git
    # configuration run during the dirty-file check, nor permit lazy fetches.
    config = git(repo, env, "config", "--local", "--no-includes", "--null",
                 "--name-only", "--list").split(b"\0")
    if any(key.startswith((b"include.", b"includeif.", b"filter."))
           or key in (b"extensions.partialclone", b"extensions.worktreeconfig")
           or (key.startswith(b"remote.") and key.endswith(b".promisor"))
           for key in map(bytes.lower, config)):
        raise ValueError(f"{repo.name}: unsupported local Git config")
    git_root = Path(os.fsdecode(git(repo, env, "rev-parse", "--show-toplevel").rstrip(b"\n")))
    if git_root.resolve() != repo:
        raise ValueError(f"{repo.name}: unexpected Git root")
    # Read the literal local configured URL, not an insteadOf-rewritten one.
    origins = git(repo, env, "config", "--local", "--null", "--get-all", "remote.origin.url")
    if origins.count(b"\0") != 1:
        raise ValueError(f"{repo.name}: expected exactly one origin")
    validate_origin(repo.name, os.fsdecode(origins[:-1]))
    head = git(repo, env, "rev-parse", "--verify", "HEAD^{commit}").strip().decode("ascii")
    if head != pin["commit"].lower():
        raise ValueError(f"{repo.name}: HEAD does not match the snapshot commit")
    if git(repo, env, "rev-parse", "--abbrev-ref", "HEAD").strip() != b"HEAD":
        raise ValueError(f"{repo.name}: HEAD must be detached")

    index = git(repo, env, "ls-files", "-v", "-z").split(b"\0")[:-1]
    if any(row[:1] != b"H" for row in index):
        raise ValueError(f"{repo.name}: hidden, conflicted or sparse index entry")
    index_entries = git(repo, env, "ls-files", "--stage", "-z").split(b"\0")[:-1]
    if any(row.split(b" ", 1)[0] not in (b"100644", b"100755") for row in index_entries):
        raise ValueError(f"{repo.name}: symlinks and submodules are not valid suite inputs")
    entry = Path("plugin", f"{repo.name}.vim")
    if (not (repo / entry).is_file() or (repo / entry).resolve() != repo / entry
            or os.fsencode(str(entry)) not in {row.split(b"\t", 1)[1] for row in index_entries}):
        raise ValueError(f"{repo.name}: missing real, tracked entry {entry}")
    if git(repo, env, "status", "--porcelain=v1", "-z", "--untracked-files=all",
           "--ignored=matching", "--ignore-submodules=none"):
        raise ValueError(f"{repo.name}: dirty checkout (including ignored files)")
    return head


def preflight(snapshot, home):
    names = declared_plugins()
    pins = read_pins(snapshot, names)
    root = clean_home(home, names)
    # Read trusted, prepared checkouts without inheriting the invoking user's
    # HOME, Git settings, repository overrides, or index-refresh writes.
    with tempfile.TemporaryDirectory(prefix="vimrc-pinned-git-") as private:
        env = {
            "HOME": private,
            "XDG_CONFIG_HOME": private,
            "PATH": os.environ.get("PATH", os.defpath),
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_OPTIONAL_LOCKS": "0",
            "GIT_NO_REPLACE_OBJECTS": "1",
            "GIT_NO_LAZY_FETCH": "1",
        }
        return {name: verify_checkout(root / name, pins[name], env) for name in sorted(names)}


def run_full(snapshot, home, verified):
    """Build the exact SimplePlug daemon offline and leave the inputs clean."""
    if "simpleplug" not in verified:
        raise ValueError("SimplePlug must be included in the exact suite")
    input_home = home.resolve()
    with tempfile.TemporaryDirectory(prefix="vimrc-pinned-full-") as temporary:
        private = Path(temporary)
        home = private / "home"
        shutil.copytree(input_home, home, symlinks=True)
        if preflight(snapshot, home) != verified:
            raise ValueError("copied checkout set does not match the pinned input")
        plug = home / ".vim/plugged/simpleplug"
        bindir = plug / "lib"
        common = {
            "HOME": str(home),
            "PATH": os.environ.get("PATH", os.defpath),
            "TERM": os.environ.get("TERM", "xterm"),
            "LANG": os.environ.get("LANG", "C.UTF-8"),
            "XDG_STATE_HOME": str(private / "state"),
            "XDG_CONFIG_HOME": str(private / "config"),
            "XDG_CACHE_HOME": str(private / "cache"),
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_NO_REPLACE_OBJECTS": "1",
            "GIT_NO_LAZY_FETCH": "1",
            "GIT_TERMINAL_PROMPT": "0",
            "VIMRC_SKIP_UPDATE_CHECK": "1",
        }
        runtime = os.environ.get("VIMRUNTIME")
        if runtime:
            common["VIMRUNTIME"] = runtime
        build = {**common, "CARGO_TARGET_DIR": str(private / "target")}
        # Do not modify PRIVATE_HOME by initializing Cargo's cache there.
        # The caller chooses a trusted, already populated registry/toolchain.
        for key in ("CARGO_HOME", "RUSTUP_HOME"):
            path = os.environ.get(key)
            if path:
                build[key] = str(Path(path).resolve())
        if "CARGO_HOME" not in build:
            build["CARGO_HOME"] = str(Path.home() / ".cargo")
        subprocess.run(
            ["cargo", "build", "--release", "--locked", "--offline",
             "--bin", "simpleplug-daemon"],
            cwd=plug, env=build, check=True,
        )
        artifact = private / "target/release/simpleplug-daemon"
        if not artifact.is_file() or artifact.is_symlink() or not os.access(artifact, os.X_OK):
            raise ValueError("locked build did not create a regular executable")
        if preflight(snapshot, home) != verified:
            raise ValueError("pinned snapshot or checkout set changed after the build")

        # Preflight rejects ignored files, so stale binaries cannot pass as a
        # successful build. Make only our own temporary installation; never
        # overwrite anything even if a concurrent process created lib.
        bindir.mkdir(mode=0o700)
        installed = bindir / "simpleplug-daemon"
        try:
            shutil.copyfile(artifact, installed)
            installed.chmod(0o700)
            vcs = hashlib.sha256(artifact.read_bytes()).hexdigest()
            print(f"pinned full: SimplePlug {verified['simpleplug']} daemon sha256={vcs}",
                  flush=True)
            subprocess.run(
                [str(Path(__file__).with_name("check.sh")), "--full"],
                env=common, check=True,
            )
        finally:
            installed.unlink(missing_ok=True)
            bindir.rmdir()
        if preflight(snapshot, home) != verified:
            raise ValueError("pinned snapshot or checkout set changed during the smoke gate")
    if preflight(snapshot, input_home) != verified:
        raise ValueError("pinned inputs changed during the smoke gate")
    print(f"pinned full: {len(verified)} exact checkouts passed vimrc --full; "
          "SimpleRemote cross-plugin daemon/host checks not covered")

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run-full", action="store_true", help="run the pinned Vim smoke gate")
    parser.add_argument("snapshot", type=Path, help="trusted SimplePlug v1 snapshot")
    parser.add_argument("private_home", type=Path, help="owned mode-0700 test HOME")
    args = parser.parse_args()
    try:
        verified = preflight(args.snapshot, args.private_home)
        if args.run_full:
            run_full(args.snapshot, args.private_home, verified)
            return
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        label = "pinned full" if args.run_full else "pinned preflight"
        parser.exit(1, f"{label}: {exc}\n")
    # No partial success receipt, and never confuse commit validation with runtime proof.
    for name, oid in verified.items():
        print(f"{name} {oid}")
    print(f"pinned preflight: {len(verified)} checkouts verified; no plugins executed")


if __name__ == "__main__":
    main()
