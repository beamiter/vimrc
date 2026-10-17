#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

readonly SIMPLEPLUG_URL="https://github.com/beamiter/simpleplug.git"

force=0
target=""

usage() {
  cat <<'EOF'
Usage: utils/bootstrap-simpleplug.sh [--force] [TARGET]

Install the latest SimplePlug default branch transactionally. TARGET defaults
to ~/.vim/plugged/simpleplug and must be an absolute path named simpleplug.
Existing checkouts, including local changes, are preserved in a backup.
Concurrent bootstraps for the same target are rejected before downloading.

Options:
  --force     replace an already complete installation with the latest one
  -h, --help  show this help
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf 'BOOTSTRAP %-8s %s\n' "$1" "$2"
}

while (($# > 0)); do
  case "$1" in
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      (($# <= 1)) || die "at most one TARGET is supported"
      if (($# == 1)); then
        [[ -z "$target" ]] || die "at most one TARGET is supported"
        target="$1"
        shift
      fi
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$target" ]] || die "at most one TARGET is supported"
      target="$1"
      shift
      ;;
  esac
done

if [[ -z "$target" ]]; then
  [[ -n "${HOME:-}" && "$HOME" == /* && "$HOME" != "/" ]] \
    || die "HOME must be an absolute, non-root path"
  [[ -d "$HOME" ]] || die "HOME must be an existing directory"
  bootstrap_home="$(cd -- "$HOME" && pwd -P)"
  [[ "$bootstrap_home" != / ]] || die "HOME must not resolve to the filesystem root"
  target="$bootstrap_home/.vim/plugged/simpleplug"
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=utils/path-utils.sh
source -- "$script_dir/path-utils.sh"

target="${target%/}"
[[ "$target" == /* && "${target##*/}" == "simpleplug" ]] \
  || die "TARGET must be an absolute path whose final component is simpleplug"
parent="$(canonicalize_dir_with_missing_tail "${target%/*}")" \
  || die "TARGET parent cannot be resolved safely"
[[ "$parent" != "/" ]] || die "refusing to install SimplePlug directly below /"
target="$parent/simpleplug"

is_complete() {
  [[ -f "$target/autoload/simpleplug.vim" \
      && -f "$target/plugin/simpleplug.vim" \
      && -x "$target/lib/simpleplug-daemon" ]]
}

if ((force == 0)) && is_complete; then
  log "SKIP" "SimplePlug is already complete at $target"
  exit 0
fi

command -v git >/dev/null 2>&1 || die "git is required to bootstrap SimplePlug"
command -v cargo >/dev/null 2>&1 || die "Cargo is required to build SimplePlug"
command -v rustc >/dev/null 2>&1 || die "Rust is required to build SimplePlug"

mkdir -p -- "$parent"
lock_dir="$parent/.simpleplug.bootstrap.lock"
lock_owned=0
stage=""
backup=""
committed=0
active_job=""

cleanup() {
  local status=$?
  trap '' INT TERM HUP
  set +e

  # Each slow command owns a process group. Stop its entire build tree before
  # deleting staging, so cancelling Vim cannot leave cargo/rustc writing into
  # a removed directory. These processes only operate on disposable staging.
  if [[ -n "$active_job" ]]; then
    kill -TERM -- "-$active_job" 2>/dev/null
    kill -KILL -- "-$active_job" 2>/dev/null
    wait "$active_job" 2>/dev/null
  fi
  if ((status != 0 && committed == 0)); then
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) ]]; then
      if [[ ! -e "$target" && ! -L "$target" ]]; then
        mv -- "$backup" "$target"
      else
        printf 'warning: installation target exists; previous checkout kept at %s\n' \
          "$backup" >&2
      fi
    fi
  fi
  if [[ -n "${stage:-}" && -d "$stage" ]]; then
    rm -rf -- "$stage"
  fi
  if ((lock_owned)); then
    rm -f -- "$lock_dir/pid"
    rmdir -- "$lock_dir"
  fi
  return "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

if ! mkdir -- "$lock_dir" 2>/dev/null; then
  die "bootstrap lock exists or cannot be created: $lock_dir; ensure no bootstrap is running before removing a stale lock"
fi
lock_owned=1
printf '%s\n' "$$" >"$lock_dir/pid"

# The previous process may have completed between our first check and locking.
if ((force == 0)) && is_complete; then
  log "SKIP" "SimplePlug is already complete at $target"
  exit 0
fi

stage="$(mktemp -d "$parent/.simpleplug.stage.XXXXXX")"
checkout="$stage/simpleplug"

run_step() {
  local status=0

  # Bash job control creates a private process group without requiring Linux's
  # setsid/flock utilities. wait remains interruptible by our signal traps.
  set -m
  "$@" &
  active_job=$!
  set +m
  wait "$active_job" || status=$?
  active_job=""
  return "$status"
}

export GIT_TERMINAL_PROMPT=0
log "FETCH" "cloning the latest SimplePlug default branch"
run_step git clone --quiet --depth 1 --single-branch "$SIMPLEPLUG_URL" "$checkout"

log "BUILD" "building and verifying simpleplug-daemon"
# The positional argument belongs to the child shell, not this shell.
# shellcheck disable=SC2016
run_step bash -c 'cd -- "$1" && exec bash ./install.sh' bash "$checkout"

[[ -f "$checkout/autoload/simpleplug.vim" \
    && -f "$checkout/plugin/simpleplug.vim" \
    && -x "$checkout/lib/simpleplug-daemon" ]] \
  || die "the staged SimplePlug installation failed verification"

revision="$(git -C "$checkout" rev-parse --short=12 HEAD)"
[[ -n "$revision" ]] || die "cannot identify the staged SimplePlug revision"

if [[ -e "$target" || -L "$target" ]]; then
  backup_root="$parent/.vimrc-bootstrap-backups"
  mkdir -p -- "$backup_root"
  backup="$backup_root/simpleplug.$(date -u +%Y%m%dT%H%M%SZ).$$"
  suffix=0
  while [[ -e "$backup" || -L "$backup" ]]; do
    ((suffix += 1))
    backup="$backup_root/simpleplug.$(date -u +%Y%m%dT%H%M%SZ).$$.$suffix"
  done
  mv -- "$target" "$backup"
  log "BACKUP" "$target -> $backup"
fi

# Refuse an unexpected replacement instead of moving checkout inside it.
if [[ -e "$target" || -L "$target" ]] \
    || ! mv -- "$checkout" "$target"; then
  die "failed to activate the staged SimplePlug installation"
fi
committed=1

log "DONE" "SimplePlug $revision installed at $target"
if [[ -n "$backup" ]]; then
  log "SAVED" "previous installation kept at $backup"
fi
