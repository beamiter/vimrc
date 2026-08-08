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

# A failed eager bootstrap is transactional: restore the previous vimrc and
# remove the private staging directory. Fake tools keep this test offline.
failure_home="$tmp/failure-home"
fake_bin="$tmp/fake-bin"
mkdir -p "$failure_home" "$fake_bin"
printf 'restore-me\n' >"$failure_home/.vimrc"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'exit 42' >"$fake_bin/git"
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

# A successful bootstrap clones the remote's current default-branch HEAD,
# builds in staging, preserves an incomplete checkout and activates atomically.
success_home="$tmp/success-home"
success_target="$success_home/.vim/plugged/simpleplug"
fake_git_log="$tmp/fake-git.log"
mkdir -p "$success_target"
printf 'preserve-local-change\n' >"$success_target/local-change"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -eu' \
  'printf "%s\\n" "$*" >>"$FAKE_GIT_LOG"' \
  'if [[ "${1:-}" == "clone" ]]; then' \
  '  checkout="${@: -1}"' \
  '  mkdir -p "$checkout/autoload" "$checkout/plugin" "$checkout/.git"' \
  '  printf "vim9script\\n" >"$checkout/autoload/simpleplug.vim"' \
  '  printf "vim9script\\n" >"$checkout/plugin/simpleplug.vim"' \
  '  printf "#!/usr/bin/env bash\\nset -eu\\nmkdir -p lib\\n: >lib/simpleplug-daemon\\nchmod 0755 lib/simpleplug-daemon\\n" >"$checkout/install.sh"' \
  'elif [[ "${1:-}" == "-C" && "${3:-}" == "rev-parse" ]]; then' \
  '  printf "69e15f5e4a59\\n"' \
  'fi' \
  'exit 0' >"$fake_bin/git"
chmod +x "$fake_bin/git"

FAKE_GIT_LOG="$fake_git_log" PATH="$fake_bin:$PATH" HOME="$success_home" \
  "$installer" --bootstrap-simpleplug >/dev/null
[[ "$success_home/.vimrc" -ef "$repo_root/.vimrc" ]]
[[ -f "$success_target/autoload/simpleplug.vim" ]]
[[ -f "$success_target/plugin/simpleplug.vim" ]]
[[ -x "$success_target/lib/simpleplug-daemon" ]]
[[ "$(find "$success_home/.vim/plugged/.vimrc-bootstrap-backups" \
      -name local-change -exec sed -n '1p' {} \; -quit)" == \
      "preserve-local-change" ]]
[[ "$(sed -n '1p' "$fake_git_log")" == \
      *"clone"*"--depth 1"*"--single-branch"* ]]
[[ -z "$(find "$success_home" -name '.simpleplug.stage.*' -print -quit)" ]]

# The automatic (non-forced) path is idempotent and performs no network call
# once all required manager files are present.
: >"$fake_git_log"
FAKE_GIT_LOG="$fake_git_log" PATH="$fake_bin:$PATH" HOME="$success_home" \
  "$repo_root/utils/bootstrap-simpleplug.sh" "$success_target" >/dev/null
[[ ! -s "$fake_git_log" ]]

if "$repo_root/utils/bootstrap-simpleplug.sh" /simpleplug >/dev/null 2>&1; then
  printf 'root-level SimplePlug target unexpectedly succeeded\n' >&2
  exit 1
fi

printf 'installer smoke: OK\n'
