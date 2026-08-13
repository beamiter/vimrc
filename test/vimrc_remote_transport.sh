#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

mkdir -p "$tmp/home" "$tmp/state" "$tmp/remote"

PATH="$repo_root/test/fixtures/simpleremote:$PATH" \
HOME="$tmp/home" \
XDG_STATE_HOME="$tmp/state" \
VIMRC_SKIP_PLUGINS=1 \
VIMRC_SKIP_UPDATE_CHECK=1 \
VIMRC_TEST_REMOTE_AGENT="$repo_root/utils/simpleremote-agent.sh" \
VIMRC_TEST_REMOTE_ROOT="$tmp/remote" \
VIMRC_TEST_REMOTE_TARGET=fixture-container \
VIMRC_TEST_DOCKER_LOG="$tmp/docker.log" \
  timeout --kill-after=2s 15s \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_remote_transport.vim"

mapfile -t docker_log <"$tmp/docker.log"
# This asserts a literal remote $HOME reference.
# shellcheck disable=SC2016
expected_command='arg=exec "$HOME"/'"'"'.cache/vimrc/agent dir/simpleremote-agent.sh'"'"''
[[ ${#docker_log[@]} -eq 7 ]]
[[ ${docker_log[0]} == 'argc=6' ]]
[[ ${docker_log[1]} == 'arg=exec' ]]
[[ ${docker_log[2]} == 'arg=-i' ]]
[[ ${docker_log[3]} == 'arg=fixture-container' ]]
[[ ${docker_log[4]} == 'arg=sh' ]]
[[ ${docker_log[5]} == 'arg=-lc' ]]
[[ ${docker_log[6]} == "$expected_command" ]]

printf 'vimrc remote docker transport: OK\n'
