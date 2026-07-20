#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

readonly SIMPLEPLUG_URL="https://github.com/beamiter/simpleplug.git"
readonly SIMPLEPLUG_REV="751ed1aa68b2d8b0b32c304a8dc73ad9d7ba50e7"

profile="core"
dry_run=0
bootstrap_simpleplug=0

usage() {
  cat <<'EOF'
Usage: utils/install.sh [options]

Safely link this repository's Vim configuration.

Options:
  --profile core|full       core: ~/.vimrc only (default)
                            full: also install the global SimpleCC config
  --bootstrap-simpleplug    explicitly download and build pinned SimplePlug
  --dry-run                 print the plan without changing files or networking
  -h, --help                show this help

The default path is offline: it never runs git, cargo, Vim, sudo, or a package
manager. Installing the remaining plugins is always a separate, explicit
:PlugInstall action.
EOF
}

die_usage() {
  printf 'error: %s\n\n' "$*" >&2
  usage >&2
  exit 2
}

log() {
  printf '%-9s %s\n' "$1" "$2"
}

while (($# > 0)); do
  case "$1" in
    --profile)
      (($# >= 2)) || die_usage "--profile requires core or full"
      profile="$2"
      shift 2
      ;;
    --bootstrap-simpleplug)
      bootstrap_simpleplug=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      (($# == 0)) || die_usage "positional arguments are not supported"
      ;;
    -*)
      die_usage "unknown option: $1"
      ;;
    *)
      die_usage "positional arguments are not supported: $1"
      ;;
  esac
done

case "$profile" in
  core|full) ;;
  *) die_usage "unknown profile: $profile" ;;
esac

[[ -n "${HOME:-}" ]] || {
  printf 'error: HOME is empty\n' >&2
  exit 1
}
[[ "$HOME" == /* && "$HOME" != "/" ]] || {
  printf 'error: HOME must be an absolute, non-root path\n' >&2
  exit 1
}
[[ -d "$HOME" ]] || {
  printf 'error: HOME must be an existing directory\n' >&2
  exit 1
}
HOME="$(cd -- "$HOME" && pwd -P)"
[[ "$HOME" != "/" ]] || {
  printf 'error: HOME must not resolve to the filesystem root\n' >&2
  exit 1
}
export HOME

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"

canonicalize_dir_with_missing_tail() {
  local path="${1%/}"
  local component
  local resolved
  local -a missing=()

  [[ -n "$path" ]] || path="/"
  while [[ ! -e "$path" && ! -L "$path" ]]; do
    component="${path##*/}"
    missing=("$component" "${missing[@]}")
    path="${path%/*}"
    [[ -n "$path" ]] || path="/"
  done
  [[ -d "$path" ]] || return 1
  if ! resolved="$(cd -- "$path" && pwd -P)"; then
    return 1
  fi
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

sources=("$repo_root/.vimrc")
targets=("$HOME/.vimrc")

if [[ "$profile" == "full" ]]; then
  config_home="${XDG_CONFIG_HOME:-"$HOME/.config"}"
  [[ "$config_home" == /* ]] || {
    printf 'error: XDG_CONFIG_HOME must be an absolute path\n' >&2
    exit 1
  }
  if ! config_home="$(canonicalize_dir_with_missing_tail "$config_home")"; then
    printf 'error: XDG_CONFIG_HOME cannot be resolved safely\n' >&2
    exit 1
  fi
  [[ "$config_home" != "/" ]] || {
    printf 'error: XDG_CONFIG_HOME must not resolve to the filesystem root\n' >&2
    exit 1
  }
  sources+=("$repo_root/simplecc.json")
  targets+=("$config_home/simplecc/simplecc.json")
fi

for source_path in "${sources[@]}"; do
  [[ -f "$source_path" ]] || {
    printf 'error: source file is missing: %s\n' "$source_path" >&2
    exit 1
  }
done

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
created_targets=()
created_sources=()
backup_paths=()
bootstrap_staging=""
bootstrap_target=""
bootstrap_backup=""
bootstrap_activated=0
transaction_committed=0

unique_backup_path() {
  local target="$1"
  local candidate="${target}.backup.${timestamp}.$$"
  local suffix=0

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    ((suffix += 1))
    candidate="${target}.backup.${timestamp}.$$.${suffix}"
  done
  printf '%s\n' "$candidate"
}

rollback_links() {
  local index target source_path backup

  for ((index = ${#created_targets[@]} - 1; index >= 0; index--)); do
    target="${created_targets[index]}"
    source_path="${created_sources[index]}"
    backup="${backup_paths[index]}"

    if [[ -L "$target" && -e "$source_path" && "$target" -ef "$source_path" ]]; then
      rm -- "$target"
    fi
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) ]]; then
      mv -- "$backup" "$target"
    fi
  done
}

install_link() {
  local source_path="$1"
  local target="$2"
  local parent backup=""

  if [[ -e "$target" && "$target" -ef "$source_path" ]]; then
    log "SKIP" "$target already points to $source_path"
    return
  fi

  parent="$(dirname -- "$target")"
  if ((dry_run)); then
    log "DRY-RUN" "mkdir -p $parent"
    if [[ -e "$target" || -L "$target" ]]; then
      backup="$(unique_backup_path "$target")"
      log "DRY-RUN" "backup $target -> $backup"
    fi
    log "DRY-RUN" "link $target -> $source_path"
    return
  fi

  mkdir -p -- "$parent"
  if [[ -e "$target" || -L "$target" ]]; then
    backup="$(unique_backup_path "$target")"
    mv -- "$target" "$backup"
  fi

  # Register the mutation before any logging or linking can fail so the EXIT
  # transaction always knows how to restore it.
  created_targets+=("$target")
  created_sources+=("$source_path")
  backup_paths+=("$backup")

  if [[ -n "$backup" ]]; then
    log "BACKUP" "$target -> $backup"
  fi

  if ! ln -s -- "$source_path" "$target"; then
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) ]]; then
      mv -- "$backup" "$target"
    fi
    printf 'error: failed to link %s\n' "$target" >&2
    return 1
  fi

  log "LINK" "$target -> $source_path"
}

bootstrap_simpleplug_fn() {
  local plugin_parent="$HOME/.vim/plugged"
  local plugin_target="$plugin_parent/simpleplug"
  local checkout=""
  local backup=""
  local install_complete=0

  if [[ -f "$plugin_target/autoload/simpleplug.vim" \
        && -f "$plugin_target/plugin/simpleplug.vim" \
        && -x "$plugin_target/lib/simpleplug-daemon" ]]; then
    install_complete=1
  fi

  if ((dry_run)); then
    if ((install_complete)); then
      log "DRY-RUN" "replace unverified SimplePlug at $plugin_target"
    fi
    log "DRY-RUN" "fetch pinned SimplePlug $SIMPLEPLUG_REV"
    log "DRY-RUN" "build and install simpleplug-daemon"
    log "DRY-RUN" "activate $plugin_target"
    return
  fi

  command -v git >/dev/null 2>&1 || {
    printf 'error: git is required for --bootstrap-simpleplug\n' >&2
    return 1
  }
  command -v cargo >/dev/null 2>&1 || {
    printf 'error: cargo is required for --bootstrap-simpleplug\n' >&2
    return 1
  }

  mkdir -p -- "$plugin_parent"
  bootstrap_staging="$(mktemp -d "$plugin_parent/.simpleplug.stage.XXXXXX")"
  bootstrap_target="$plugin_target"
  checkout="$bootstrap_staging/simpleplug"

  mkdir -- "$checkout"
  git -C "$checkout" init --quiet
  git -C "$checkout" remote add origin "$SIMPLEPLUG_URL"
  git -C "$checkout" fetch --quiet --depth 1 origin "$SIMPLEPLUG_REV"
  git -C "$checkout" checkout --quiet --detach FETCH_HEAD

  (
    cd -- "$checkout"
    cargo build --release --locked
    mkdir -p lib
    install -m 0755 target/release/simpleplug-daemon lib/simpleplug-daemon
  )

  [[ -f "$checkout/autoload/simpleplug.vim" \
        && -f "$checkout/plugin/simpleplug.vim" \
        && -x "$checkout/lib/simpleplug-daemon" ]] || {
    printf 'error: staged SimplePlug failed verification\n' >&2
    return 1
  }

  if [[ -e "$plugin_target" || -L "$plugin_target" ]]; then
    backup="$(unique_backup_path "$plugin_target")"
    mv -- "$plugin_target" "$backup"
    bootstrap_backup="$backup"
    log "BACKUP" "$plugin_target -> $backup"
  fi

  if ! mv -- "$checkout" "$plugin_target"; then
    if [[ -n "$backup" && ( -e "$backup" || -L "$backup" ) ]]; then
      mv -- "$backup" "$plugin_target"
      bootstrap_backup=""
    fi
    printf 'error: failed to activate SimplePlug\n' >&2
    return 1
  fi
  bootstrap_activated=1

  rm -rf -- "$bootstrap_staging"
  bootstrap_staging=""
  log "INSTALL" "SimplePlug $SIMPLEPLUG_REV -> $plugin_target"
}

cleanup_transaction() {
  local status=$?
  set +e

  if ((status != 0 && transaction_committed == 0)); then
    if ((bootstrap_activated)) && [[ -n "$bootstrap_target" ]]; then
      rm -rf -- "$bootstrap_target"
    fi
    if [[ -n "$bootstrap_backup" \
          && ( -e "$bootstrap_backup" || -L "$bootstrap_backup" ) \
          && ! -e "$bootstrap_target" \
          && ! -L "$bootstrap_target" ]]; then
      mv -- "$bootstrap_backup" "$bootstrap_target"
    fi
    rollback_links
  fi

  if [[ -n "$bootstrap_staging" && -d "$bootstrap_staging" ]]; then
    rm -rf -- "$bootstrap_staging"
  fi
  return "$status"
}

trap cleanup_transaction EXIT

for index in "${!sources[@]}"; do
  install_link "${sources[index]}" "${targets[index]}"
done

if ((bootstrap_simpleplug)); then
  bootstrap_simpleplug_fn
fi

if ((dry_run)); then
  log "DONE" "dry run completed; no files changed"
else
  log "DONE" "profile $profile installed"
fi

transaction_committed=1
trap - EXIT

if ((bootstrap_simpleplug)); then
  printf '\nNext (explicit network action): open Vim and run :PlugInstall\n'
else
  printf '\nSimplePlug was not downloaded. To bootstrap the pinned manager explicitly:\n'
  printf '  %s --bootstrap-simpleplug\n' "$0"
fi
