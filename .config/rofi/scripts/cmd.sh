#!/usr/bin/env bash
set -euo pipefail

# rofi passes the selected line as arguments
choice="${*:-}"

# Focus existing window by app_id; if not found, launch flatpak app id
focus_or_run_flatpak() {
  local app_id="$1"
  local flatpak_id="$2"

  (
    # Let rofi close first to avoid focus races
    sleep 0.05
    swaymsg "[app_id=\"${app_id}\"] focus" >/dev/null 2>&1 \
      || flatpak run "${flatpak_id}" >/dev/null 2>&1 &
  ) >/dev/null 2>&1 &
}

# "Label|sway_app_id|flatpak_app_id"
APPS=(
  "KeepassXC|org.keepassxc.KeePassXC|org.keepassxc.KeePassXC"
  "LocalSend|localsend|org.localsend.localsend_app"
)

if [[ -z "$choice" ]]; then
  for entry in "${APPS[@]}"; do
    IFS='|' read -r label _ _ <<<"$entry"
    printf '%s\n' "$label"
  done
  exit 0
fi

for entry in "${APPS[@]}"; do
  IFS='|' read -r label app_id flatpak_id <<<"$entry"
  if [[ "$choice" == "$label" ]]; then
    focus_or_run_flatpak "$app_id" "$flatpak_id"
    exit 0
  fi
done

exit 0
