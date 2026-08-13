#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
cleanup() {
  local name fixture_pid
  for name in ssh agent responses; do
    fixture_pid=''
    if [[ -r "$tmp/gates/$name.pid" ]]; then
      fixture_pid=$(<"$tmp/gates/$name.pid")
    fi
    if [[ "$fixture_pid" =~ ^[0-9]+$ ]] \
        && kill -0 "$fixture_pid" 2>/dev/null; then
      kill "$fixture_pid" 2>/dev/null || true
    fi
  done
  rm -rf -- "$tmp"
}
trap cleanup EXIT

remote_root="$tmp/remote"
mkdir -p "$tmp/home" "$tmp/state" "$tmp/gates" "$remote_root"
printf '{"fixture": true}\n' >"$remote_root/simplecc.json"
printf 'first line\nsecond line\n' >"$remote_root/notes.txt"
printf 'generation snapshot\npending across reconnect\n' >"$tmp/expected-notes.txt"
printf 'scratch sentinel\n' >"$tmp/scratch.txt"

PATH="$repo_root/test/fixtures/simpleremote:$PATH" \
HOME="$tmp/home" \
XDG_STATE_HOME="$tmp/state" \
VIMRC_SKIP_PLUGINS=1 \
VIMRC_SKIP_UPDATE_CHECK=1 \
VIMRC_TEST_REMOTE_AGENT="$repo_root/utils/simpleremote-agent.sh" \
VIMRC_TEST_REMOTE_AGENT_COMMAND="$repo_root/test/fixtures/simpleremote/agent wrapper" \
VIMRC_TEST_REMOTE_ROOT="$remote_root" \
VIMRC_TEST_REMOTE_TARGET=fixture-target \
VIMRC_TEST_SCRATCH_FILE="$tmp/scratch.txt" \
VIMRC_TEST_SSH_LOG="$tmp/ssh.log" \
VIMRC_TEST_GATE_DIR="$tmp/gates" \
  timeout --kill-after=2s 15s \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_remote.vim"

cmp "$tmp/expected-notes.txt" "$remote_root/notes.txt"

mapfile -t ssh_log <"$tmp/ssh.log"
[[ ${#ssh_log[@]} -eq 6 ]]
[[ ${ssh_log[0]} == 'argc=5' ]]
[[ ${ssh_log[1]} == 'arg=-T' ]]
[[ ${ssh_log[2]} == 'arg=fixture-target' ]]
[[ ${ssh_log[3]} == 'arg=sh' ]]
[[ ${ssh_log[4]} == 'arg=-c' ]]
expected_ssh_command="arg='exec '\''$repo_root/test/fixtures/simpleremote/agent wrapper'\'''"
[[ ${ssh_log[5]} == "$expected_ssh_command" ]]

printf 'vimrc remote integration: OK\n'
