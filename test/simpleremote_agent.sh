#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
agent="$repo_root/utils/simpleremote-agent.sh"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

b64() {
  base64 | tr -d '\n'
}

request() {
  local id=$1
  local operation=$2
  local payload=${3-}

  printf '%s\t%s\t' "$id" "$operation"
  printf '%s' "$payload" | b64
  printf '\n'
}

assert_response() {
  local index=$1
  local expected_id=$2
  local expected_status=$3
  local expected_payload=$4
  local actual_id actual_status actual_payload extra

  IFS=$'\t' read -r actual_id actual_status actual_payload extra \
    <<<"${responses[$index]}"
  [[ "$actual_id" == "$expected_id" ]]
  [[ "$actual_status" == "$expected_status" ]]
  [[ "$actual_payload" == "$expected_payload" ]]
  [[ -z "$extra" ]]
}

read_file="$tmp/read.txt"
config_file="$tmp/simplecc.json"
write_file="$tmp/write.txt"
invalid_write_file="$tmp/invalid-write.txt"
symlink_target="$tmp/symlink-target.txt"
symlink_file="$tmp/symlink-write.txt"
unreadable_file="$tmp/unreadable.txt"
unreadable_path="$unreadable_file"
missing_file="$tmp/missing.txt"
expected_write="$tmp/expected-write.txt"
list_dir="$tmp/list"
printf -v long_name '%0240d' 0
long_write_file="$tmp/$long_name"
responses_file="$tmp/responses"

printf 'read-one\nread-two\n' >"$read_file"
printf '{"fixture":true}\n' >"$config_file"
printf 'old contents\n' >"$write_file"
printf 'must remain unchanged\n' >"$invalid_write_file"
printf 'link target stays unchanged\n' >"$symlink_target"
ln -s "$symlink_target" "$symlink_file"
printf 'secret\n' >"$unreadable_file"
chmod 000 "$unreadable_file"
if [[ $(id -u) -eq 0 && -f /proc/1/mem ]]; then
  unreadable_path=/proc/1/mem
fi
chmod 0751 "$write_file"
printf 'tabs\there\nblank follows\n\nthree final newlines\n\n\n' >"$expected_write"
mkdir -p "$list_dir/directory"
printf 'plain\n' >"$list_dir/plain.txt"
printf 'hidden\n' >"$list_dir/.hidden"
ln -s directory "$list_dir/link"

read_content_b64=$(b64 <"$read_file")
write_content_b64=$(b64 <"$expected_write")
write_payload=$(printf '%s\t%s' "$write_file" "$write_content_b64")
invalid_write_payload=$(printf '%s\t%s' "$invalid_write_file" '%%%')
symlink_write_payload=$(printf '%s\t%s' "$symlink_file" \
  "$(printf 'replacement\n' | b64)")
long_write_payload=$(printf '%s\t%s' "$long_write_file" \
  "$(printf 'long filename works\n' | b64)")

{
  request 1 ping
  request 2 read "$read_file"
  request 3 read "$missing_file"
  request 4 write "$write_payload"
  request 5 exec "printf 'exec ok\\n'"
  request 6 exec "printf 'exec failed\\n' >&2; exit 7"
  request 7 grep "printf 'grep ok\\n'"
  request 8 grep "printf 'grep failed\\n' >&2; exit 3"
  request 9 made-up-operation
  request 10 read-config "$config_file"
  request 11 list "$list_dir"
  printf '%s\n' $'12\tread\t%%%'
  request 13 write "$invalid_write_payload"
  request 14 ping
  request 15 read "$unreadable_path"
  # $stolen is intentionally expanded by the agent shell.
  # shellcheck disable=SC2016
  request 16 exec 'if IFS= read -r stolen; then printf "stole:%s\n" "$stolen"; else printf "stdin closed\n"; fi'
  request 17 ping
  request 18 write "$symlink_write_payload"
  request 19 write "$long_write_payload"
} | "$agent" >"$responses_file"

mapfile -t responses <"$responses_file"
[[ ${#responses[@]} -eq 19 ]]

assert_response 0 1 ok "$(printf 'simpleremote/2' | b64)"
assert_response 1 2 ok "$(printf '%s' "$read_content_b64" | b64)"
assert_response 2 3 error "$(printf 'not a file: %s' "$missing_file" | b64)"
assert_response 3 4 ok "$(printf '%s' "$write_file" | b64)"
assert_response 4 5 ok "$(printf 'exec ok\n' | b64)"
assert_response 5 6 error "$(printf 'exec failed\n' | b64)"
assert_response 6 7 ok "$(printf 'grep ok\n' | b64)"
assert_response 7 8 error "$(printf 'grep failed\n' | b64)"
assert_response 8 9 error \
  "$(printf 'unknown operation: made-up-operation' | b64)"
assert_response 9 10 ok "$(b64 <"$config_file" | b64)"
assert_response 10 11 ok "$(printf 'directory\td\nlink\tl\nplain.txt\tf\n.hidden\tf\n' | b64)"
assert_response 11 12 error "$(printf 'invalid read payload' | b64)"
assert_response 12 13 error \
  "$(printf 'cannot decode/write: %s' "$invalid_write_file" | b64)"
assert_response 13 14 ok "$(printf 'simpleremote/2' | b64)"
assert_response 14 15 error "$(printf 'cannot read: %s' "$unreadable_path" | b64)"
assert_response 15 16 ok "$(printf 'stdin closed\n' | b64)"
assert_response 16 17 ok "$(printf 'simpleremote/2' | b64)"
assert_response 17 18 error \
  "$(printf 'refusing to replace symbolic link: %s' "$symlink_file" | b64)"
assert_response 18 19 ok "$(printf '%s' "$long_write_file" | b64)"

cmp "$expected_write" "$write_file"
cmp <(printf 'must remain unchanged\n') "$invalid_write_file"
[[ -L "$symlink_file" ]]
cmp <(printf 'link target stays unchanged\n') "$symlink_target"
cmp <(printf 'long filename works\n') "$long_write_file"
[[ "$(stat -c '%a' "$write_file")" == 751 ]]

printf 'simpleremote agent protocol: OK\n'
