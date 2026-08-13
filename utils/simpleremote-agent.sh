#!/bin/sh
set -eu

command_output=
encode_output=
tmp=
list_output=
cleanup() {
  [ -z "$command_output" ] || rm -f "$command_output"
  [ -z "$encode_output" ] || rm -f "$encode_output"
  [ -z "$tmp" ] || rm -f "$tmp"
  [ -z "$list_output" ] || rm -f "$list_output"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# SimpleRemote's deliberately boring remote half.  The local Vim owns all UI;
# this process only moves bytes and executes commands in the remote workspace.
# Protocol: id<TAB>operation<TAB>base64(payload), one request per line.

if printf '' | base64 -d >/dev/null 2>&1; then
  decode_flag=-d
elif printf '' | base64 -D >/dev/null 2>&1; then
  decode_flag=-D
else
  printf 'simpleremote: base64 decoder is unavailable\n' >&2
  exit 69
fi

decode() { printf '%s' "$1" | base64 "$decode_flag" 2>/dev/null; }
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
run_command() {
  command_id=$1
  command_text=$2
  command_output=$(mktemp "${TMPDIR:-/tmp}/simpleremote-command.XXXXXX") || {
    reply "$command_id" error "cannot create command output file"
    return
  }

  # The RPC stream belongs to the agent.  A user command such as `cat` or
  # `read` must never consume the next protocol request from stdin.
  if sh -lc "$command_text" </dev/null >"$command_output" 2>&1; then
    command_reply=ok
  else
    command_reply=error
  fi
  reply_stream "$command_id" "$command_reply" <"$command_output"
  rm -f "$command_output"
  command_output=
}
encode_file() {
  encode_path=$1
  encode_output=$(mktemp "${TMPDIR:-/tmp}/simpleremote-base64.XXXXXX") || return 1
  if ! base64 2>/dev/null <"$encode_path" >"$encode_output"; then
    rm -f "$encode_output"
    return 1
  fi
  tr -d '\n' <"$encode_output"
  encode_status=$?
  rm -f "$encode_output"
  encode_output=
  return "$encode_status"
}
list_directory() {
  list_root=$1
  for list_entry in "$list_root"/* "$list_root"/.[!.]* "$list_root"/..?*; do
    if [ ! -e "$list_entry" ] && [ ! -L "$list_entry" ]; then
      continue
    fi
    list_name=${list_entry##*/}
    if [ -L "$list_entry" ]; then
      list_kind=l
    elif [ -d "$list_entry" ]; then
      list_kind=d
    else
      list_kind=f
    fi
    printf '%s\t%s\n' "$list_name" "$list_kind"
  done 2>/dev/null
}

tab=$(printf '\t')
while IFS="$tab" read -r id op payload; do
  [ -n "${id:-}" ] || continue
  case "$op" in
    ping)
      reply "$id" ok "simpleremote/2"
      ;;
    read)
      if ! path=$(decode "${payload:-}"); then
        reply "$id" error "invalid read payload"
        continue
      fi
      if [ -f "$path" ]; then
        if file_data=$(encode_file "$path" 2>/dev/null); then
          reply "$id" ok "$file_data"
        else
          reply "$id" error "cannot read: $path"
        fi
      else
        reply "$id" error "not a file: $path"
      fi
      ;;
    read-config)
      if ! path=$(decode "${payload:-}"); then
        reply "$id" error "invalid read-config payload"
        continue
      fi
      if [ -f "$path" ]; then
        if file_data=$(encode_file "$path" 2>/dev/null); then
          reply "$id" ok "$file_data"
        else
          reply "$id" error "cannot read: $path"
        fi
      else
        reply "$id" error "config not found: $path"
      fi
      ;;
    write)
      # The outer payload is decoded by the operation handler.  The resulting
      # value is path<TAB>base64(content).  Keeping content encoded while it is
      # in a shell variable avoids command substitution stripping final LFs.
      if ! decoded=$(decode "${payload:-}"); then
        reply "$id" error "invalid write payload"
        continue
      fi
      case "$decoded" in
        *"$tab"*)
          path=${decoded%%"$tab"*}
          data=${decoded#*"$tab"}
          ;;
        *)
          reply "$id" error "invalid write payload"
          continue
          ;;
      esac
      if [ -z "$path" ]; then
        reply "$id" error "invalid write path"
        continue
      fi
      if [ -L "$path" ]; then
        reply "$id" error "refusing to replace symbolic link: $path"
        continue
      fi

      directory=$(dirname "$path")
      if ! mkdir -p "$directory"; then
        reply "$id" error "cannot create directory: $directory"
        continue
      fi
      if ! tmp=$(mktemp "$directory/.simpleremote.XXXXXX"); then
        reply "$id" error "cannot create temporary file: $path"
        continue
      fi
      # cp -p is specified by POSIX and gives the replacement the existing
      # file's mode before its contents are replaced.  This keeps executable
      # scripts executable without depending on GNU chmod --reference.
      if [ -e "$path" ] && ! cp -p "$path" "$tmp"; then
        rm -f "$tmp"
        reply "$id" error "cannot preserve permissions: $path"
        continue
      fi
      if ! printf '%s' "$data" | base64 "$decode_flag" >"$tmp" 2>/dev/null; then
        rm -f "$tmp"
        reply "$id" error "cannot decode/write: $path"
        continue
      fi
      if mv "$tmp" "$path"; then
        tmp=
        reply "$id" ok "$path"
      else
        rm -f "$tmp"
        tmp=
        reply "$id" error "cannot replace: $path"
      fi
      ;;
    list)
      if ! path=$(decode "${payload:-}"); then
        reply "$id" error "invalid list payload"
        continue
      fi
      if [ -d "$path" ]; then
        if [ ! -r "$path" ] || [ ! -x "$path" ]; then
          reply "$id" error "cannot list directory: $path"
          continue
        fi
        list_output=$(mktemp "${TMPDIR:-/tmp}/simpleremote-list.XXXXXX") || {
          reply "$id" error "cannot create list output file"
          continue
        }
        if list_directory "$path" >"$list_output"; then
          reply_stream "$id" ok <"$list_output"
        else
          reply "$id" error "cannot list directory: $path"
        fi
        rm -f "$list_output"
        list_output=
      else
        reply "$id" error "not a directory: $path"
      fi
      ;;
    grep)
      if ! query=$(decode "${payload:-}"); then
        reply "$id" error "invalid grep payload"
        continue
      fi
      # The query is a shell command supplied by the local trusted config.
      run_command "$id" "$query"
      ;;
    exec)
      if ! command=$(decode "${payload:-}"); then
        reply "$id" error "invalid exec payload"
        continue
      fi
      run_command "$id" "$command"
      ;;
    *)
      reply "$id" error "unknown operation: $op"
      ;;
  esac
done
