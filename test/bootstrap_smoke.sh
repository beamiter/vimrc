#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bootstrap="$repo_root/utils/bootstrap-simpleplug.sh"
tmp="$(mktemp -d)"
running_pid=""
cleanup() {
  if [[ -n "$running_pid" ]]; then
    kill -TERM "$running_pid" 2>/dev/null || true
    wait "$running_pid" 2>/dev/null || true
  fi
  rm -rf -- "$tmp"
}
trap cleanup EXIT

fail() {
  printf 'bootstrap smoke: %s\n' "$*" >&2
  exit 1
}

wait_for_file() {
  local attempts=0
  while [[ ! -s "$1" ]]; do
    ((attempts += 1))
    ((attempts < 250)) || fail "timed out waiting for fixture: $1"
    sleep 0.02
  done
}

fake_bin="$tmp/bin"
mkdir "$fake_bin"
cat >"$fake_bin/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$BOOTSTRAP_GIT_LOG"
if [[ "${1:-}" == clone ]]; then
  [[ "${BOOTSTRAP_MODE:-}" != clone-failure ]] || exit 42
  checkout="${@: -1}"
  mkdir -p "$checkout/autoload" "$checkout/plugin" "$checkout/.git"
  printf 'vim9script\n' >"$checkout/autoload/simpleplug.vim"
  printf 'vim9script\n' >"$checkout/plugin/simpleplug.vim"
  cat >"$checkout/install.sh" <<'BUILD'
#!/usr/bin/env bash
set -euo pipefail
case "${BOOTSTRAP_MODE:-}" in
  build-failure) exit 43 ;;
  incomplete) exit 0 ;;
  slow)
    sleep 30 &
    child_pid=$!
    printf '%s\n' "$child_pid" >"$BOOTSTRAP_READY"
    wait "$child_pid"
    ;;
esac
mkdir -p lib
printf '#!/bin/sh\nexit 0\n' >lib/simpleplug-daemon
chmod 0755 lib/simpleplug-daemon
BUILD
elif [[ "${1:-}" == -C && "${3:-}" == rev-parse ]]; then
  printf '123456789abc\n'
else
  exit 44
fi
EOF
printf '#!/bin/sh\nexit 0\n' >"$fake_bin/cargo"
printf '#!/bin/sh\nexit 0\n' >"$fake_bin/rustc"
chmod +x "$fake_bin/git" "$fake_bin/cargo" "$fake_bin/rustc"
export PATH="$fake_bin:$PATH"
export BOOTSTRAP_GIT_LOG="$tmp/git.log"
export BOOTSTRAP_READY="$tmp/build.ready"

target="$tmp/plugin path/simpleplug"
mkdir -p "$target"
printf 'uncommitted work\n' >"$target/local-change"

for failure in clone-failure build-failure incomplete; do
  if BOOTSTRAP_MODE="$failure" "$bootstrap" "$target" >"$tmp/failure.log" 2>&1; then
    fail "$failure unexpectedly succeeded"
  fi
  [[ "$(cat "$target/local-change")" == 'uncommitted work' ]]
  [[ ! -e "$tmp/plugin path/.simpleplug.bootstrap.lock" ]]
  [[ -z "$(find "$tmp/plugin path" -name '.simpleplug.stage.*' -print -quit)" ]]
done

# Concurrent invocations fail before cloning, and cannot steal the first lock.
BOOTSTRAP_MODE=slow "$bootstrap" "$target" >"$tmp/slow.log" 2>&1 &
running_pid=$!
wait_for_file "$BOOTSTRAP_READY"
build_child="$(cat "$BOOTSTRAP_READY")"
before="$(cat "$BOOTSTRAP_GIT_LOG")"
if "$bootstrap" "$target" >"$tmp/concurrent.log" 2>&1; then
  fail 'concurrent bootstrap unexpectedly succeeded'
fi
[[ "$(cat "$BOOTSTRAP_GIT_LOG")" == "$before" ]]
[[ "$(cat "$tmp/plugin path/.simpleplug.bootstrap.lock/pid")" == "$running_pid" ]]

# Cancelling the shell promptly stops the build process tree and releases both
# staging and the lock. The old checkout must remain unchanged.
kill -TERM "$running_pid"
status=0
wait "$running_pid" || status=$?
running_pid=""
[[ "$status" == 143 ]] || fail "cancelled bootstrap exited $status"
[[ "$(cat "$target/local-change")" == 'uncommitted work' ]]
[[ ! -e "$tmp/plugin path/.simpleplug.bootstrap.lock" ]]
[[ -z "$(find "$tmp/plugin path" -name '.simpleplug.stage.*' -print -quit)" ]]
if kill -0 "$build_child" 2>/dev/null; then
  # An orphan may briefly remain a zombie until PID 1 reaps it. Avoid ps,
  # which cannot inspect itself in some isolated CI execution environments.
  child_stat="$(cat "/proc/$build_child/stat" 2>/dev/null || true)"
  [[ "$child_stat" == *') Z '* ]] || ! kill -0 "$build_child" 2>/dev/null \
    || fail "cancelled build left a running child: $build_child"
fi

# A complete install is immediately reusable; a forced update safely backs up
# both ordinary files and a symlink to a developer's checkout.
"$bootstrap" "$target" >/dev/null
[[ -x "$target/lib/simpleplug-daemon" ]]
backup="$(find "$tmp/plugin path/.vimrc-bootstrap-backups" -name local-change -print -quit)"
[[ "$(cat "$backup")" == 'uncommitted work' ]]
before="$(cat "$BOOTSTRAP_GIT_LOG")"
"$bootstrap" "$target" >/dev/null
[[ "$(cat "$BOOTSTRAP_GIT_LOG")" == "$before" ]]

developer_checkout="$tmp/developer checkout"
mkdir "$developer_checkout"
printf 'developer source\n' >"$developer_checkout/local-change"
symlink_parent="$tmp/symlink plugins"
mkdir "$symlink_parent"
ln -s "$developer_checkout" "$symlink_parent/simpleplug"
"$bootstrap" --force "$symlink_parent/simpleplug" >/dev/null
[[ ! -L "$symlink_parent/simpleplug" ]]
[[ "$(cat "$developer_checkout/local-change")" == 'developer source' ]]
backup_link="$(find "$symlink_parent/.vimrc-bootstrap-backups" -type l -print -quit)"
[[ "$(readlink "$backup_link")" == "$developer_checkout" ]]

# The argument separator must not silently accept a second target.
if "$bootstrap" "$target" -- "$target" >/dev/null 2>&1; then
  fail 'two targets separated by -- unexpectedly succeeded'
fi
ln -s / "$tmp/root-link"
if "$bootstrap" "$tmp/missing/../root-link/simpleplug" >/dev/null 2>&1; then
  fail 'root-resolving target unexpectedly succeeded'
fi
if HOME=/tmp/.. "$bootstrap" >/dev/null 2>&1; then
  fail 'root-resolving HOME unexpectedly succeeded'
fi

# Signal cancellation must also unwind an installer's previously changed links.
cancel_home="$tmp/cancel-home"
mkdir "$cancel_home"
printf 'original vimrc\n' >"$cancel_home/.vimrc"
rm "$BOOTSTRAP_READY"
HOME="$cancel_home" BOOTSTRAP_MODE=slow \
  "$repo_root/utils/install.sh" --bootstrap-simpleplug >"$tmp/install-cancel.log" 2>&1 &
running_pid=$!
wait_for_file "$BOOTSTRAP_READY"
kill -TERM "$running_pid"
status=0
wait "$running_pid" || status=$?
running_pid=""
[[ "$status" == 143 ]] || fail "cancelled installer exited $status"
[[ ! -L "$cancel_home/.vimrc" ]]
[[ "$(cat "$cancel_home/.vimrc")" == 'original vimrc' ]]
[[ -z "$(find "$cancel_home" \( -name '*.lock' -o -name '.simpleplug.stage.*' -o -name '*.backup.*' \) -print -quit)" ]]

printf 'bootstrap smoke: OK\n'
