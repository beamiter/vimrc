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
  target="$HOME/.vim/plugged/simpleplug"
fi

canonicalize_dir_with_missing_tail() {
  local path="${1%/}"
  local component resolved
  local -a missing=()

  [[ -n "$path" ]] || path="/"
  while [[ ! -e "$path" && ! -L "$path" ]]; do
    component="${path##*/}"
    missing=("$component" "${missing[@]}")
    path="${path%/*}"
    [[ -n "$path" ]] || path="/"
  done
  [[ -d "$path" ]] || return 1
  resolved="$(cd -- "$path" && pwd -P)" || return 1
  path="$resolved"

  for component in "${missing[@]}"; do
    case "$component" in
      ""|.) ;;
      ..)
        if [[ "$path" != "/" ]]; then
          path="${path%/*}"
          [[ -n "$path" ]] || path="/"
        fi
        ;;
      *) path="${path%/}/$component" ;;
    esac
  done
  printf '%s\n' "$path"
}

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
stage="$(mktemp -d "$parent/.simpleplug.stage.XXXXXX")"
checkout="$stage/simpleplug"
backup=""
activated=0
committed=0

cleanup() {
  local status=$?
  set +e

  if ((status != 0 && committed == 0)); then
    if ((activated)) && [[ -e "$target" || -L "$target" ]]; then
      mv -- "$target" "$stage/failed-simpleplug"
    fi
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) \
          && ! -e "$target" && ! -L "$target" ]]; then
      mv -- "$backup" "$target"
    fi
  fi
  if [[ -n "${stage:-}" && -d "$stage" ]]; then
    rm -rf -- "$stage"
  fi
  return "$status"
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

export GIT_TERMINAL_PROMPT=0
log "FETCH" "cloning the latest SimplePlug default branch"
git clone --quiet --depth 1 --single-branch "$SIMPLEPLUG_URL" "$checkout"

log "BUILD" "building and verifying simpleplug-daemon"
(
  cd -- "$checkout"
  bash ./install.sh
)

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
  mv -- "$target" "$backup"
  log "BACKUP" "$target -> $backup"
fi

if ! mv -- "$checkout" "$target"; then
  if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) ]]; then
    mv -- "$backup" "$target"
    backup=""
  fi
  die "failed to activate the staged SimplePlug installation"
fi
activated=1

rm -rf -- "$stage"
stage=""
committed=1
trap - EXIT
trap - INT TERM HUP

log "DONE" "SimplePlug $revision installed at $target"
if [[ -n "$backup" ]]; then
  log "SAVED" "previous installation kept at $backup"
fi
