#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

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
  --bootstrap-simpleplug    eagerly download and build the latest SimplePlug
  --dry-run                 print the plan without changing files or networking
  -h, --help                show this help

The installer itself is offline by default: it never runs git, cargo, Vim,
sudo, or a package manager. On the first Vim launch, the vimrc automatically
bootstraps SimplePlug and continues with :PlugUpdate in the same session.
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
install_home="$(cd -- "$HOME" && pwd -P)"
[[ "$install_home" != "/" ]] || {
  printf 'error: HOME must not resolve to the filesystem root\n' >&2
  exit 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/.." && pwd -P)"

# shellcheck source=utils/path-utils.sh
source -- "$script_dir/path-utils.sh"

sources=("$repo_root/.vimrc")
targets=("$install_home/.vimrc")

if [[ "$profile" == "full" ]]; then
  config_home="${XDG_CONFIG_HOME:-"$install_home/.config"}"
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
transaction_committed=0
install_lock="$install_home/.vimrc.install.lock"
lock_owned=0
bootstrap_pid=""

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
      if [[ ! -e "$target" && ! -L "$target" ]]; then
        mv -- "$backup" "$target"
      else
        printf 'warning: target changed during installation; backup kept at %s\n' \
          "$backup" >&2
      fi
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
  fi

  # Register the mutation before moving the target, logging or linking so the EXIT
  # transaction always knows how to restore it.
  created_targets+=("$target")
  created_sources+=("$source_path")
  backup_paths+=("$backup")

  if [[ -n "$backup" ]]; then
    mv -- "$target" "$backup"
    log "BACKUP" "$target -> $backup"
  fi

  if [[ -e "$target" || -L "$target" ]] \
      || ! ln -s -- "$source_path" "$target"; then
    printf 'error: failed to link %s\n' "$target" >&2
    return 1
  fi

  log "LINK" "$target -> $source_path"
}

bootstrap_simpleplug_fn() {
  local plugin_target="$install_home/.vim/plugged/simpleplug"

  if ((dry_run)); then
    log "DRY-RUN" "fetch and build the latest SimplePlug"
    log "DRY-RUN" "transactionally activate $plugin_target"
    return
  fi
  "$script_dir/bootstrap-simpleplug.sh" --force "$plugin_target" &
  bootstrap_pid=$!
  wait "$bootstrap_pid"
  bootstrap_pid=""
}

cleanup_transaction() {
  local status=$?
  trap '' INT TERM HUP
  set +e

  if [[ -n "$bootstrap_pid" ]]; then
    kill -TERM "$bootstrap_pid" 2>/dev/null
    wait "$bootstrap_pid" 2>/dev/null
  fi
  if ((status != 0 && transaction_committed == 0)); then
    rollback_links
  fi
  if ((lock_owned)); then
    rm -f -- "$install_lock/pid"
    rmdir -- "$install_lock"
  fi
  return "$status"
}

trap cleanup_transaction EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

if ((dry_run == 0)); then
  if ! mkdir -- "$install_lock" 2>/dev/null; then
    printf 'error: installation lock exists or cannot be created: %s\n' "$install_lock" >&2
    printf 'Ensure no installer is running before removing a stale lock.\n' >&2
    exit 1
  fi
  lock_owned=1
  printf '%s\n' "$$" >"$install_lock/pid"
fi

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

if ((bootstrap_simpleplug)); then
  printf '\nLatest SimplePlug installed. Open Vim; remaining plugins will install automatically.\n'
else
  printf '\nOpen Vim once; it will bootstrap SimplePlug and install all plugins automatically.\n'
fi
