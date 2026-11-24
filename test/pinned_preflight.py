#!/usr/bin/env python3
"""Run the opt-in suite preflight against owned local checkout fixtures."""
from contextlib import redirect_stdout
import importlib.util
from io import StringIO
import json
import os
import shlex
from pathlib import Path
import subprocess
import tempfile
import sys
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("preflight", ROOT / "utils/pinned-preflight.py")
PREFLIGHT = importlib.util.module_from_spec(SPEC)
sys.dont_write_bytecode = True
SPEC.loader.exec_module(PREFLIGHT)
REAL_PLUG = os.environ.get("VIMRC_TEST_REAL_SIMPLEPLUG")


class PinnedPreflight(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="vimrc-preflight-fixture-")
        self.addCleanup(directory.cleanup)
        self.base = Path(directory.name)
        self.home = self.base / "home"
        self.home.mkdir(mode=0o700)
        self.root = self.home / ".vim/plugged"
        self.root.mkdir(parents=True)
        self.snapshot = self.base / "plugins.lock"
        self.env = {
            "HOME": str(self.home),
            "PATH": os.environ.get("PATH", os.defpath),
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
        }
        self.names = PREFLIGHT.declared_plugins()
        self.pins = {}
        self.repo = self.root / "simplecc"
        self.vim_entry = self.repo / "plugin/simplecc.vim"
        for name in self.names:
            repo = self.root / name
            (repo / "plugin").mkdir(parents=True)
            # If any fixture plugin is sourced, this side effect exposes it.
            (repo / "plugin" / f"{name}.vim").write_text(
                "call writefile(['not allowed'], $HOME .. '/unexpected-runtime')\n",
                encoding="utf-8",
            )
            (repo / ".gitignore").write_text("ignored-vim/\n", encoding="utf-8")
            self.git(repo, "init", "-q")
            url = f"https://github.com/beamiter/{name}.git"
            self.git(repo, "remote", "add", "origin", url)
            self.git(repo, "add", ".")
            self.git(repo, "commit", "-qm", "synthetic plugin")
            self.git(repo, "checkout", "-q", "--detach")
            self.pins[name] = {"commit": self.git(repo, "rev-parse", "HEAD").strip(), "url": url}
        self.write_snapshot()

    def git(self, repo, *args):
        return subprocess.run(
            ["git", "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
             "-C", str(repo), *args],
            check=True, text=True, capture_output=True, timeout=10, env=self.env,
        ).stdout

    def write_snapshot(self):
        self.snapshot.write_text(json.dumps({"version": 1, "plugins": self.pins}), encoding="utf-8")

    def verify(self, diagnostic=None, env=None):
        result = subprocess.run(
            [str(ROOT / "utils/check.sh"), "--pinned-preflight", str(self.snapshot), str(self.home)],
            text=True, capture_output=True, timeout=20, env=env or self.env,
        )
        self.assertFalse((self.home / "unexpected-runtime").exists(), "must not source plugins")
        if diagnostic is None:
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(f"{len(self.names)} checkouts verified; no plugins executed", result.stdout)
            self.assertEqual({line.split()[0] for line in result.stdout.splitlines()[:-1]}, self.names)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
            self.assertIn(diagnostic, result.stderr)
            self.assertEqual("", result.stdout, "must not emit a partial success receipt")

    def test_clean_exact_commits_and_optional_branch(self):
        self.pins["simplecc"]["branch"] = ""
        self.write_snapshot()
        old_index = self.repo / ".git/index"
        before = (old_index.read_bytes(), old_index.stat().st_mtime_ns)
        self.verify(env={**self.env, "GIT_DIR": "wrong", "GIT_WORK_TREE": "wrong",
                         "GIT_INDEX_FILE": "wrong"})
        self.assertEqual(before, (old_index.read_bytes(), old_index.stat().st_mtime_ns))

    def test_missing_checkout(self):
        self.repo.rename(self.base / "removed")
        self.verify("checkout root must match registry exactly (missing: simplecc)")

    def test_no_extra_checkout(self):
        (self.root / "unexpected").mkdir()
        self.verify("checkout root must match registry exactly")

    def test_no_symlink_checkout(self):
        moved = self.base / "moved"
        self.repo.rename(moved)
        self.repo.symlink_to(moved, target_is_directory=True)
        self.verify("expected a real checkout")

    def test_no_git_ancestor_or_repository_override(self):
        (self.repo / ".git").rename(self.base / "removed-git")
        self.verify("expected a real checkout")

    def test_dirty_and_hidden_inputs(self):
        self.vim_entry.write_text("vim9script\n", encoding="utf-8")
        self.verify("dirty checkout")
        self.git(self.repo, "update-index", "--assume-unchanged", "plugin/simplecc.vim")
        self.verify("hidden, conflicted or sparse index entry")
        self.git(self.repo, "update-index", "--no-assume-unchanged", "plugin/simplecc.vim")
        self.git(self.repo, "restore", "plugin/simplecc.vim")
        extra = self.repo / "plugin/extra.vim"
        extra.touch()
        self.verify("dirty checkout")
        extra.unlink()
        (self.repo / "ignored-vim").mkdir()
        (self.repo / "ignored-vim/extra.vim").touch()
        self.verify("dirty checkout")

    def test_rejects_config_that_can_execute_or_fetch(self):
        self.git(self.repo, "config", "filter.fixture.clean", "false")
        self.verify("unsupported local Git config")
        self.git(self.repo, "config", "--unset", "filter.fixture.clean")
        self.git(self.repo, "config", "remote.origin.promisor", "true")
        self.verify("unsupported local Git config")

    def test_untracked_or_symlink_runtime(self):
        self.vim_entry.rename(self.repo / "target.vim")
        self.vim_entry.symlink_to("../target.vim")
        self.git(self.repo, "add", ".")
        self.git(self.repo, "commit", "-qm", "not a valid runtime tree")
        self.pins["simplecc"]["commit"] = self.git(self.repo, "rev-parse", "HEAD").strip()
        self.write_snapshot()
        self.verify("symlinks and submodules are not valid suite inputs")

    def test_wrong_ref_and_managed_branch(self):
        exact = self.pins["simplecc"]["commit"]
        self.pins["simplecc"]["commit"] = "0" * 40
        self.write_snapshot()
        self.verify("HEAD does not match")
        self.pins["simplecc"]["commit"] = exact
        self.write_snapshot()
        self.git(self.repo, "checkout", "-qb", "owned-branch")
        self.verify("HEAD must be detached")

    def test_wrong_origin_and_duplicate_origin(self):
        self.git(self.repo, "remote", "set-url", "origin", "https://github.com/other/simplecc.git")
        self.verify("unexpected origin")
        self.git(self.repo, "remote", "set-url", "origin", self.pins["simplecc"]["url"])
        self.git(self.repo, "remote", "set-url", "--add", "origin", self.pins["simplecc"]["url"])
        self.verify("expected exactly one origin")

    def test_disallows_stale_or_wrong_pins(self):
        self.pins["simplecc"]["branch"] = "master"
        self.write_snapshot()
        self.verify("branch does not match")
        del self.pins["simplecc"]
        self.write_snapshot()
        self.verify("snapshot must match registry exactly (missing: simplecc)")
        self.snapshot.write_text('{"version":1,"version":1,"plugins":{}}', encoding="utf-8")
        self.verify("duplicate JSON key")

    def test_home_has_no_self_selected_hooks(self):
        self.home.chmod(0o755)
        self.verify("must be a real, owned directory of mode 0700")
        self.home.chmod(0o700)
        (self.home / ".vimrc.local").touch()
        self.verify("PRIVATE_HOME must contain only .vim/plugged")

    def test_registry_cannot_silently_ignore_aliases_or_custom_runtime(self):
        registry = self.base / "plugins.vim"
        for options in ("as: 'other'", "rtp: 'nested'", "branch: 'old'"):
            with self.subTest(options=options), patch.object(PREFLIGHT, "REGISTRY", registry):
                registry.write_text(
                    f"simpleplug#Plug('beamiter/simplecc', {{{options}}})\n", encoding="utf-8",
                )
                with self.assertRaisesRegex(ValueError, "unsupported .* declaration"):
                    PREFLIGHT.declared_plugins()

    def test_full_rejects_dirty_inputs_before_cargo(self):
        self.vim_entry.write_text("vim9script\n", encoding="utf-8")
        bin_dir = self.base / "bin"
        bin_dir.mkdir()
        marker = self.base / "cargo-was-started"
        cargo = bin_dir / "cargo"
        cargo.write_text(f'#!/bin/sh\n: > {shlex.quote(str(marker))}\n', encoding="utf-8")
        cargo.chmod(0o700)
        result = subprocess.run(
            [str(ROOT / "utils/check.sh"), "--pinned-full", str(self.snapshot), str(self.home)],
            env={**self.env, "PATH": f"{bin_dir}:{self.env['PATH']}"},
            text=True, capture_output=True, timeout=20,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("dirty checkout", result.stderr)
        self.assertEqual("", result.stdout)
        self.assertFalse(marker.exists())

    def test_full_cleans_clone_on_failed_smoke(self):
        verified = PREFLIGHT.preflight(self.snapshot, self.home)
        real_run = subprocess.run
        copied_home = None
        original_lib = self.root / "simpleplug/lib"

        def controlled(argv, **kwargs):
            nonlocal copied_home
            if argv[0] == "cargo":
                self.assertEqual(
                    argv[1:], ["build", "--release", "--locked", "--offline",
                               "--bin", "simpleplug-daemon"],
                )
                copied_home = Path(kwargs["env"]["HOME"])
                self.assertNotEqual(self.home, copied_home)
                self.assertEqual(copied_home / ".vim/plugged/simpleplug", kwargs["cwd"])
                target = Path(kwargs["env"]["CARGO_TARGET_DIR"])
                artifact = target / "release/simpleplug-daemon"
                artifact.parent.mkdir(parents=True)
                artifact.write_bytes(b"owned wrapper fixture; never executed")
                artifact.chmod(0o700)
                return subprocess.CompletedProcess(argv, 0)
            if Path(argv[0]).name == "check.sh":
                self.assertEqual(argv[1:], ["--full"])
                self.assertFalse(original_lib.exists())
                self.assertEqual("1", kwargs["env"]["VIMRC_SKIP_UPDATE_CHECK"])
                clone_lib = copied_home / ".vim/plugged/simpleplug/lib"
                self.assertTrue((clone_lib / "simpleplug-daemon").exists())
                raise subprocess.CalledProcessError(19, argv)
            return real_run(argv, **kwargs)

        output = StringIO()
        with patch.object(PREFLIGHT.subprocess, "run", side_effect=controlled):
            with redirect_stdout(output), self.assertRaises(subprocess.CalledProcessError):
                PREFLIGHT.run_full(self.snapshot, self.home, verified)
        self.assertNotIn("exact checkouts passed", output.getvalue())
        self.assertIsNotNone(copied_home)
        self.assertFalse(copied_home.exists())
        self.assertFalse(original_lib.exists())
        self.assertEqual(verified, PREFLIGHT.preflight(self.snapshot, self.home))

    @unittest.skipUnless(REAL_PLUG, "set VIMRC_TEST_REAL_SIMPLEPLUG to an owned SimplePlug checkout")
    def test_real_vim_plugsnapshot_v1_roundtrip(self):
        plugin = Path(REAL_PLUG).resolve(strict=True)
        script = self.base / "emit_snapshot.vim"
        # Register precisely the current suite declarations, but do not call
        # End(): generating a snapshot needs neither the daemon nor test code.
        registry = PREFLIGHT.REGISTRY.read_text(encoding="utf-8").splitlines()
        declarations = [line.strip() for line in registry
                        if PREFLIGHT.DECLARATION.fullmatch(line.strip())]
        self.snapshot.unlink()
        script.write_text(
            "\n".join(["vim9script",
                      "execute 'set runtimepath^=' .. fnameescape($REAL_PLUG)",
                      "runtime plugin/simpleplug.vim",
                      "simpleplug#Begin($FIXTURE_PLUGGED)"]
                      + declarations
                      + ["execute 'PlugSnapshot ' .. fnameescape($SNAPSHOT)",
                         "qall!"]) + "\n",
            encoding="utf-8",
        )
        result = subprocess.run(
            ["vim", "-Nu", "NONE", "-n", "-i", "NONE", "-es", "-V1", "-S", str(script)],
            text=True, capture_output=True, timeout=30,
            env={**self.env, "VIMRUNTIME": os.environ.get("VIMRUNTIME", ""),
                 "REAL_PLUG": str(plugin), "FIXTURE_PLUGGED": str(self.root),
                 "SNAPSHOT": str(self.snapshot)},
        )
        self.assertEqual(0, result.returncode, result.stderr)
        actual = json.loads(self.snapshot.read_bytes())
        self.assertEqual({"version": 1, "plugins": self.pins}, actual)
        self.verify()


if __name__ == "__main__":
    unittest.main()
