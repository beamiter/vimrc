#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

required=(vim git)
build=(cargo rustc)
optional=(rg jq wl-copy xclip xsel)
failures=0

check_group() {
  local title="$1"
  shift
  local tool

  printf '%s\n' "$title"
  for tool in "$@"; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf '  [OK]   %-12s %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  [MISS] %s\n' "$tool"
      if [[ "$title" == "Required" ]]; then
        failures=$((failures + 1))
      fi
    fi
  done
}

check_group "Required" "${required[@]}"
check_group "Plugin builds" "${build[@]}"
check_group "Optional providers" "${optional[@]}"

if command -v vim >/dev/null 2>&1; then
  version_line="$(vim --version | sed -n '1p')"
  printf '\n%s\n' "$version_line"
  if vim -Nu NONE -n -i NONE -es \
      -c 'if v:version < 901 | cquit 1 | endif' \
      -c 'qall!' >/dev/null 2>&1; then
    printf '  [OK]   Vim 9.1+\n'
  else
    printf '  [MISS] Vim 9.1+\n'
    failures=$((failures + 1))
  fi
  for feature in +vim9script +job +channel +timers +popupwin +textprop +persistent_undo; do
    if vim --version | grep -q -- "$feature"; then
      printf '  [OK]   %s\n' "$feature"
    else
      printf '  [MISS] %s\n' "$feature"
      failures=$((failures + 1))
    fi
  done
fi

printf '\nThis script is read-only and never installs packages.\n'
printf 'Run ./utils/check.sh after the required dependencies are available.\n'

exit "$failures"
