#!/usr/bin/env bash
# Shared path helpers for this repository's Bash utilities.  Source this file;
# it is not meant to be executed directly.

# Resolve a directory path whose trailing components may not exist yet.
# Walks up to the nearest existing ancestor, canonicalizes it with pwd -P,
# then re-appends the missing tail (collapsing "." and ".." components).
# Prints the resolved path; returns 1 if no existing directory ancestor
# can be canonicalized.
canonicalize_dir_with_missing_tail() {
  local path="${1:-}"
  local component
  local resolved
  local -a missing=()

  # A relative missing path would never reach / in the ancestor walk.
  [[ "$path" == /* ]] || return 1
  path="${path%/}"
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

    # Collapsing a missing component followed by .. can reveal a real symlink
    # later in the tail. Resolve it too, or /missing/../root-link could bypass
    # callers' checks against a path that resolves to the filesystem root.
    if [[ -d "$path" ]]; then
      if ! resolved="$(cd -- "$path" && pwd -P)"; then
        return 1
      fi
      path="$resolved"
    elif [[ -e "$path" || -L "$path" ]]; then
      return 1
    fi
  done
  printf '%s\n' "$path"
}
