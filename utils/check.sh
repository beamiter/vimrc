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

for script in \
  "$repo_root/deps.sh" \
  "$repo_root/utils/install.sh" \
  "$repo_root/utils/check.sh" \
  "$repo_root/test/install_smoke.sh"; do
  bash -n "$script"
done

if command -v jq >/dev/null 2>&1; then
  jq empty "$repo_root/simplecc.json"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$repo_root/simplecc.json" >/dev/null
else
  printf 'warning: jq/python3 missing; JSON syntax check skipped\n' >&2
fi

"$repo_root/test/install_smoke.sh"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/home" "$tmp/state"

mkdir -p "$tmp/invalid-home-cwd"
if (
  cd "$tmp/invalid-home-cwd"
  HOME= XDG_STATE_HOME= XDG_CONFIG_HOME= VIMRC_SKIP_PLUGINS=1 \
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

if ((run_full)); then
  mkdir -p "$tmp/full-state"
  XDG_STATE_HOME="$tmp/full-state" \
    vim -Nu "$repo_root/.vimrc" -n -i NONE -es \
    -S "$repo_root/test/vimrc_full_smoke.vim"
  printf 'vimrc full smoke: OK\n'
fi

printf 'all requested checks passed\n'
