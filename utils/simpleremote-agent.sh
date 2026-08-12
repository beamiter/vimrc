#!/bin/sh
set -eu

# SimpleRemote's deliberately boring remote half.  The local Vim owns all UI;
# this process only moves bytes and executes commands in the remote workspace.
# Protocol: id<TAB>operation<TAB>base64(payload), one request per line.

decode() { printf '%s' "$1" | base64 -d 2>/dev/null; }
encode() { base64 | tr -d '\n'; }
reply() {
  printf '%s\t%s\t' "$1" "$2"
  printf '%s' "$3" | encode
  printf '\n'
}
reply_stream() {
  printf '%s\t%s\t' "$1" "$2"
  encode
  printf '\n'
}

tab=$(printf '\t')
while IFS="$tab" read -r id op payload; do
  [ -n "${id:-}" ] || continue
  case "$op" in
    ping)
      reply "$id" ok "simpleremote/1"
      ;;
    read)
      path=$(decode "${payload:-}")
      if [ -f "$path" ]; then
        reply "$id" ok "$(base64 < "$path" | tr -d '\n')"
      else
        reply "$id" error "not a file: $path"
      fi
      ;;
    read-config)
      path=$(decode "${payload:-}")
      if [ -f "$path" ]; then
        reply "$id" ok "$(base64 < "$path" | tr -d '\n')"
      else
        reply "$id" error "config not found: $path"
      fi
      ;;
    write)
      # The outer payload is decoded by the operation handler.  The resulting
      # value is path<TAB>content, where content is still base64 encoded.
      decoded=$(decode "${payload:-}")
      path=${decoded%%"$(printf '\t')"*}
      data=${decoded#*"$(printf '\t')"}
      tmp="${path}.simpleremote.$$"
      mkdir -p "$(dirname "$path")"
      if printf '%s' "$data" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$path"
        reply "$id" ok "$path"
      else
        rm -f "$tmp"
        reply "$id" error "cannot decode/write: $path"
      fi
      ;;
    list)
      path=$(decode "${payload:-}")
      if [ -d "$path" ]; then
        (find "$path" -maxdepth 1 -mindepth 1 -printf '%f\t%y\n' 2>/dev/null || ls -la "$path") | reply_stream "$id" ok
      else
        reply "$id" error "not a directory: $path"
      fi
      ;;
    grep)
      query=$(decode "${payload:-}")
      # The query is a shell command supplied by the local trusted config.
      sh -lc "$query" 2>&1 | reply_stream "$id" ok
      ;;
    exec)
      command=$(decode "${payload:-}")
      sh -lc "$command" 2>&1 | reply_stream "$id" ok
      ;;
    *)
      reply "$id" error "unknown operation: $op"
      ;;
  esac
done
