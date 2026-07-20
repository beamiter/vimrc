#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
installer="$repo_root/utils/install.sh"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

home="$tmp/home"
config="$tmp/config"
mkdir -p "$home"

before="$(find "$tmp" -mindepth 1 -print | sort)"
HOME="$home" XDG_CONFIG_HOME="$config" \
  "$installer" --profile full --bootstrap-simpleplug --dry-run >/dev/null
after="$(find "$tmp" -mindepth 1 -print | sort)"
[[ "$before" == "$after" ]]

HOME="$home" XDG_CONFIG_HOME="$config" \
  "$installer" --profile full >/dev/null
[[ -L "$home/.vimrc" ]]
[[ "$home/.vimrc" -ef "$repo_root/.vimrc" ]]
[[ -L "$config/simplecc/simplecc.json" ]]
[[ "$config/simplecc/simplecc.json" -ef "$repo_root/simplecc.json" ]]

HOME="$home" XDG_CONFIG_HOME="$config" \
  "$installer" --profile full >/dev/null
[[ -z "$(find "$tmp" -name '*.backup.*' -print -quit)" ]]

backup_home="$tmp/backup-home"
mkdir -p "$backup_home"
printf 'preserve-me\n' >"$backup_home/.vimrc"
HOME="$backup_home" "$installer" >/dev/null
backup="$(find "$backup_home" -maxdepth 1 -name '.vimrc.backup.*' -print -quit)"
[[ -n "$backup" ]]
[[ "$(sed -n '1p' "$backup")" == "preserve-me" ]]
[[ "$backup_home/.vimrc" -ef "$repo_root/.vimrc" ]]

if HOME="$home" "$installer" --profile unknown >/dev/null 2>&1; then
  printf 'invalid profile unexpectedly succeeded\n' >&2
  exit 1
fi
if HOME=/tmp/.. "$installer" --dry-run >/dev/null 2>&1; then
  printf 'root-resolving HOME unexpectedly succeeded\n' >&2
  exit 1
fi
if HOME="$home" XDG_CONFIG_HOME=/ \
    "$installer" --profile full --dry-run >/dev/null 2>&1; then
  printf 'root XDG_CONFIG_HOME unexpectedly succeeded\n' >&2
  exit 1
fi
same_file_plan="$(HOME="$repo_root" "$installer" --dry-run)"
[[ "$same_file_plan" == *"SKIP"*"already points to"* ]]
[[ "$same_file_plan" != *"backup $repo_root/.vimrc"* ]]

# A failure immediately after moving an old target must still restore it.
early_home="$tmp/early-home"
mkdir -p "$early_home"
printf 'restore-early\n' >"$early_home/.vimrc"
if (
  printf() {
    if [[ "${2:-}" == "BACKUP" ]]; then
      return 89
    fi
    builtin printf "$@"
  }
  export -f printf
  HOME="$early_home" "$installer" >/dev/null 2>&1
); then
  printf 'early link failure unexpectedly succeeded\n' >&2
  exit 1
fi
[[ ! -L "$early_home/.vimrc" ]]
[[ "$(sed -n '1p' "$early_home/.vimrc")" == "restore-early" ]]
[[ -z "$(find "$early_home" -name '*.backup.*' -print -quit)" ]]

# A failed explicit bootstrap is transactional: restore the previous vimrc and
# remove the private staging directory.  Fake tools keep this test offline.
failure_home="$tmp/failure-home"
fake_bin="$tmp/fake-bin"
mkdir -p "$failure_home" "$fake_bin"
printf 'restore-me\n' >"$failure_home/.vimrc"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'if [[ " $* " == *" fetch "* ]]; then exit 42; fi' \
  'exit 0' >"$fake_bin/git"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$fake_bin/cargo"
chmod +x "$fake_bin/git" "$fake_bin/cargo"

if PATH="$fake_bin:$PATH" HOME="$failure_home" \
    "$installer" --bootstrap-simpleplug >/dev/null 2>&1; then
  printf 'failed bootstrap unexpectedly succeeded\n' >&2
  exit 1
fi
[[ ! -L "$failure_home/.vimrc" ]]
[[ "$(sed -n '1p' "$failure_home/.vimrc")" == "restore-me" ]]
[[ -z "$(find "$failure_home" -name '*.backup.*' -print -quit)" ]]
[[ -z "$(find "$failure_home" -name '.simpleplug.stage.*' -print -quit)" ]]

# Also cover a failure after the staged plugin has been activated but before
# the transaction commits.
late_home="$tmp/late-home"
mkdir -p "$late_home"
printf 'restore-late\n' >"$late_home/.vimrc"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -e' \
  'checkout=""' \
  'if [[ "${1:-}" == "-C" ]]; then checkout="$2"; shift 2; fi' \
  'if [[ "${1:-}" == "checkout" ]]; then' \
  '  mkdir -p "$checkout/autoload" "$checkout/plugin"' \
  '  : >"$checkout/autoload/simpleplug.vim"' \
  '  : >"$checkout/plugin/simpleplug.vim"' \
  'fi' \
  'exit 0' >"$fake_bin/git"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -e' \
  'mkdir -p target/release' \
  ': >target/release/simpleplug-daemon' \
  'chmod +x target/release/simpleplug-daemon' >"$fake_bin/cargo"
chmod +x "$fake_bin/git" "$fake_bin/cargo"

if (
  printf() {
    if [[ "${2:-}" == "INSTALL" ]]; then
      return 88
    fi
    builtin printf "$@"
  }
  export -f printf
  PATH="$fake_bin:$PATH" HOME="$late_home" \
    "$installer" --bootstrap-simpleplug >/dev/null 2>&1
); then
  printf 'late bootstrap failure unexpectedly succeeded\n' >&2
  exit 1
fi
[[ ! -L "$late_home/.vimrc" ]]
[[ "$(sed -n '1p' "$late_home/.vimrc")" == "restore-late" ]]
[[ ! -e "$late_home/.vim/plugged/simpleplug" ]]
[[ -z "$(find "$late_home" -name '*.backup.*' -print -quit)" ]]
[[ -z "$(find "$late_home" -name '.simpleplug.stage.*' -print -quit)" ]]

printf 'installer smoke: OK\n'
