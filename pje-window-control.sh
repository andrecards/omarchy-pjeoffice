#!/usr/bin/env bash
set -u

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/pjeoffice-hyprland-window.state"
SPECIAL_WORKSPACE="special:pje"

window_json() {
  hyprctl clients -j 2>/dev/null | jq -c '
    [ .[]
      | select(
          ((.class // "") | test("pje|pjeoffice|br-jus-cnj"; "i"))
          or ((.initialClass // "") | test("pje|pjeoffice|br-jus-cnj"; "i"))
          or ((.title // "") | test("pje[[:space:]]*office|pjeoffice"; "i"))
          or ((.initialTitle // "") | test("pje[[:space:]]*office|pjeoffice"; "i"))
        )
    ] | first // empty'
}

read_state() {
  [ -f "$STATE_FILE" ] && . "$STATE_FILE"
}

write_state() {
  local address="$1" workspace="$2" mode="$3"
  umask 077
  printf 'address=%q\nworkspace=%q\nmode=%q\n' "$address" "$workspace" "$mode" > "$STATE_FILE"
}

clear_state() {
  rm -f "$STATE_FILE"
}

status() {
  local window address current_workspace
  window="$(window_json)"
  if [ -z "$window" ]; then
    clear_state
    printf 'ausente\n'
    return 0
  fi

  address="$(jq -r '.address' <<<"$window")"
  current_workspace="$(jq -r '.workspace.name // (.workspace.id | tostring)' <<<"$window")"
  read_state

  if [ "$current_workspace" = "$SPECIAL_WORKSPACE" ]; then
    printf 'minimizado\n'
  else
    printf 'visivel\n'
  fi
}

minimize() {
  local window address workspace id
  window="$(window_json)"
  [ -z "$window" ] && { printf 'ausente\n'; return 0; }

  address="$(jq -r '.address' <<<"$window")"
  workspace="$(jq -r '.workspace.name // (.workspace.id | tostring)' <<<"$window")"
  id="$(jq -r '.workspace.id // 0' <<<"$window")"
  [ "$workspace" = "$SPECIAL_WORKSPACE" ] || write_state "$address" "$id" "minimizado"
  hyprctl dispatch "hl.dsp.window.move({ window = \"address:$address\", workspace = \"$SPECIAL_WORKSPACE\", follow = false })" >/dev/null 2>&1 || true
  hyprctl dispatch "hl.dsp.focus({ workspace = \"$id\" })" >/dev/null 2>&1 || true
  printf 'minimizado\n'
}

restore() {
  local window current_address workspace
  window="$(window_json)"
  [ -z "$window" ] && { printf 'ausente\n'; return 0; }

  current_address="$(jq -r '.address' <<<"$window")"
  read_state
  workspace="${workspace:-1}"
  hyprctl dispatch "hl.dsp.window.move({ window = \"address:$current_address\", workspace = \"$workspace\", follow = false })" >/dev/null 2>&1 || true
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$current_address\" })" >/dev/null 2>&1 || hyprctl dispatch "focuswindow address:$current_address" >/dev/null 2>&1 || true
  write_state "$current_address" "$workspace" "mostrado"
  printf 'visivel\n'
}

auto_hide() {
  local window current_address workspace saved_address
  window="$(window_json)"
  [ -z "$window" ] && { printf 'ausente\n'; return 0; }

  current_address="$(jq -r '.address' <<<"$window")"
  workspace="$(jq -r '.workspace.name // (.workspace.id | tostring)' <<<"$window")"
  read_state
  saved_address="${address:-}"

  if [ "$workspace" != "$SPECIAL_WORKSPACE" ] && { [ "$saved_address" != "$current_address" ] || [ "${mode:-}" != "mostrado" ]; }; then
    minimize >/dev/null
  fi
  status
}

quit() {
  pkill -TERM -f 'pjeoffice-pro\.jar' 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    pgrep -f 'pjeoffice-pro\.jar' >/dev/null 2>&1 || break
    sleep 0.2
  done
  pkill -KILL -f 'pjeoffice-pro\.jar' 2>/dev/null || true
  clear_state
  printf 'encerrado\n'
}

case "${1:-status}" in
  status) status ;;
  minimize|hide) minimize ;;
  restore|show) restore ;;
  auto-hide) auto_hide ;;
  quit) quit ;;
  *) printf 'uso: %s {status|minimize|restore|auto-hide|quit}\n' "$0" >&2; exit 2 ;;
esac
