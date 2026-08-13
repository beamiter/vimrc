#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
run_full=0

case "${1:-}" in
  "") ;;
  --full) run_full=1 ;;
  -h|--help)
    printf 'Usage: utils/check.sh [--full]\n'
    printf '  --full  also test the locally installed plugin stack\n'
    exit 0
    ;;
  *)
    printf 'error: unknown option: %s\n' "$1" >&2
    exit 2
    ;;
esac

command -v vim >/dev/null 2>&1 || {
  printf 'error: Vim is required\n' >&2
  exit 1
}

# 测试保持离线：不让配置的更新检查在 CI 里访问网络。
export VIMRC_SKIP_UPDATE_CHECK=1

for script in \
  "$repo_root/deps.sh" \
  "$repo_root/utils/bootstrap-simpleplug.sh" \
  "$repo_root/utils/install.sh" \
  "$repo_root/utils/check.sh" \
  "$repo_root/test/install_smoke.sh" \
  "$repo_root/test/simpleremote_agent.sh" \
  "$repo_root/test/vimrc_remote.sh" \
  "$repo_root/test/vimrc_remote_transport.sh"; do
  bash -n "$script"
done
sh -n "$repo_root/utils/simpleremote-agent.sh"
bash -n "$repo_root/test/fixtures/simpleremote/ssh"
bash -n "$repo_root/test/fixtures/simpleremote/docker"
sh -n "$repo_root/test/fixtures/simpleremote/agent wrapper"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -s sh \
    "$repo_root/utils/simpleremote-agent.sh" \
    "$repo_root/test/fixtures/simpleremote/agent wrapper"
  shellcheck \
    "$repo_root/test/simpleremote_agent.sh" \
    "$repo_root/test/vimrc_remote.sh" \
    "$repo_root/test/vimrc_remote_transport.sh" \
    "$repo_root/test/fixtures/simpleremote/ssh" \
    "$repo_root/test/fixtures/simpleremote/docker"
fi

if command -v jq >/dev/null 2>&1; then
  jq empty "$repo_root/simplecc.json"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$repo_root/simplecc.json" >/dev/null
else
  printf 'warning: jq/python3 missing; JSON syntax check skipped\n' >&2
fi

"$repo_root/test/install_smoke.sh"
"$repo_root/test/simpleremote_agent.sh"
"$repo_root/test/vimrc_remote.sh"
"$repo_root/test/vimrc_remote_transport.sh"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/home" "$tmp/state"

mkdir -p "$tmp/invalid-home-cwd"
if (
  cd "$tmp/invalid-home-cwd"
  HOME='' XDG_STATE_HOME='' XDG_CONFIG_HOME='' VIMRC_SKIP_PLUGINS=1 \
    vim -Nu "$repo_root/.vimrc" -n -i NONE -es +qall
); then
  printf 'error: vimrc accepted an empty HOME\n' >&2
  exit 1
fi
printf 'vimrc invalid-HOME smoke: OK\n'

HOME="$tmp/home" \
XDG_STATE_HOME=/ \
XDG_CONFIG_HOME=/ \
VIMRC_SKIP_PLUGINS=1 \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_invalid_xdg.vim"
printf 'vimrc invalid-XDG smoke: OK\n'

HOME="$tmp/home" \
XDG_STATE_HOME="$tmp/state" \
VIMRC_SKIP_PLUGINS=1 \
  vim -Nu "$repo_root/.vimrc" -n -es \
  -S "$repo_root/test/vimrc_smoke.vim"
printf 'vimrc core smoke: OK\n'

printf 'not a directory\n' >"$tmp/state-blocker"
HOME="$tmp/home" \
XDG_STATE_HOME="$tmp/state-blocker/vim-state" \
VIMRC_RECOVERY_STATE="$tmp/recovered-state" \
VIMRC_SKIP_PLUGINS=1 \
  vim -Nu "$repo_root/.vimrc" -n -es \
  -S "$repo_root/test/vimrc_readonly_state.vim"
printf 'vimrc unavailable-state smoke: OK\n'

mkdir -p "$tmp/config/simplecc"
ln -s "$repo_root/simplecc.json" "$tmp/config/simplecc/simplecc.json"
HOME="$tmp/home" \
XDG_CONFIG_HOME="$tmp/config" \
XDG_STATE_HOME="$tmp/state" \
VIMRC_SKIP_PLUGINS=1 \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_xdg_config.vim"
printf 'vimrc XDG config smoke: OK\n'

mkdir -p "$tmp/override-home"
cp "$repo_root/test/fixtures/vimrc.before" "$tmp/override-home/.vimrc.before"
cp "$repo_root/test/fixtures/vimrc.local" "$tmp/override-home/.vimrc.local"
HOME="$tmp/override-home" \
XDG_STATE_HOME="$tmp/state" \
VIMRC_SKIP_PLUGINS=1 \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_overrides.vim"
printf 'vimrc local-override smoke: OK\n'

mkdir -p "$tmp/bootstrap-home" "$tmp/bootstrap-state"
cp "$repo_root/test/fixtures/vimrc.bootstrap.before" \
  "$tmp/bootstrap-home/.vimrc.before"
HOME="$tmp/bootstrap-home" \
XDG_STATE_HOME="$tmp/bootstrap-state" \
VIMRC_TEST_PLUGIN_HOME="$tmp/bootstrap-plugins" \
VIMRC_TEST_BOOTSTRAP_SCRIPT="$repo_root/test/fixtures/bootstrap-simpleplug-fixture.sh" \
VIMRC_TEST_SIMPLEPLUG_FIXTURE="$repo_root/test/fixtures/simpleplug" \
  vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
  -S "$repo_root/test/vimrc_bootstrap.vim"
printf 'vimrc one-launch bootstrap smoke: OK\n'

if ((run_full)); then
  mkdir -p "$tmp/full-state"
  XDG_STATE_HOME="$tmp/full-state" \
    vim --cmd 'let g:simpleplug_auto_install = 0' \
    -Nu "$repo_root/.vimrc" -n -i NONE -es \
    -S "$repo_root/test/vimrc_full_smoke.vim"
  printf 'vimrc full smoke: OK\n'
fi

printf 'all requested checks passed\n'
