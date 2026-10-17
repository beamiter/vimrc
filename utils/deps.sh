#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

required=(vim git)
build=(cargo rustc)
optional=(rg jq wl-copy xclip xsel)
failures=0
check_build=0

usage() {
  printf 'Usage: utils/deps.sh [--build]\n'
  printf '  --build  also require Cargo and Rust for automatic plugin installation\n'
  printf '\nRead-only diagnostics; no packages or plugins are installed.\n'
}

while (($#)); do
  case "$1" in
    --build) check_build=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

check_group() {
  local title="$1"
  local required_group="$2"
  shift 2
  local tool

  printf '%s\n' "$title"
  for tool in "$@"; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf '  [OK]   %-12s %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  [MISS] %s\n' "$tool"
      if ((required_group)); then
        failures=$((failures + 1))
      fi
    fi
  done
}

check_group "Required" 1 "${required[@]}"
check_group "Plugin builds" "$check_build" "${build[@]}"
check_group "Optional providers" 0 "${optional[@]}"

if command -v vim >/dev/null 2>&1; then
  # Capture once: repeated `vim --version | grep -q` can raise SIGPIPE under
  # pipefail and incorrectly report a feature that is actually present.
  version_output=""
  if ! version_output="$(vim --version 2>&1)"; then
    printf '\n  [MISS] vim --version failed\n'
    failures=$((failures + 1))
  fi
  printf '\n%s\n' "${version_output%%$'\n'*}"
  if vim -Nu NONE -U NONE --noplugin -n -i NONE -es \
      -c 'if v:version < 901 | cquit 1 | endif' \
      -c 'qall!' >/dev/null 2>&1; then
    printf '  [OK]   Vim 9.1+\n'
  else
    printf '  [MISS] Vim 9.1+\n'
    failures=$((failures + 1))
  fi
  version_tokens=" ${version_output//$'\n'/ } "
  version_tokens="${version_tokens//$'\t'/ }"
  for feature in +vim9script +job +channel +timers +popupwin +textprop +persistent_undo; do
    if [[ "$version_tokens" == *" $feature "* ]]; then
      printf '  [OK]   %s\n' "$feature"
    else
      printf '  [MISS] %s\n' "$feature"
      failures=$((failures + 1))
    fi
  done
fi

for tool in "${build[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    if tool_version="$("$tool" --version 2>&1)"; then
      printf '\n%s\n' "${tool_version%%$'\n'*}"
    else
      printf '\n  [MISS] %s is installed but cannot run\n' "$tool"
      if ((check_build)); then
        failures=$((failures + 1))
      fi
    fi
  fi
done

printf '\nThis script is read-only and never installs packages.\n'
if ((check_build == 0)); then
  printf 'Use --build to require the Rust toolchain for plugin installation.\n'
fi
printf 'Run ./utils/check.sh after the required dependencies are available.\n'

if ((failures)); then
  printf '\n%d required dependency checks failed.\n' "$failures" >&2
  exit 1
fi
