#!/usr/bin/env bash
set -Eeuo pipefail

target="${1:?missing SimplePlug target}"
fixture="${VIMRC_TEST_SIMPLEPLUG_FIXTURE:?missing fixture path}"

mkdir -p -- "$(dirname -- "$target")"
cp -R -- "$fixture" "$target"
chmod 0755 -- "$target/lib/simpleplug-daemon"
printf 'BOOTSTRAP DONE fixture installed at %s\n' "$target"
