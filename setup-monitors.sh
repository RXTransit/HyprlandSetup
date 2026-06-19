#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

detect_monitors() {
  local monitors=()
  for path in /sys/class/drm/*/status; do
    local status
    status=$(<"$path")
    [[ "$status" != connected ]] && continue

    local connector
    connector=$(basename "$(dirname "$path")")
    connector="${connector#*-}"

    local modes_file
    modes_file="$(dirname "$path")/modes"
    local modes=()
    if [[ -f "$modes_file" ]]; then
      while IFS= read -r mode; do
        [[ -n "$mode" ]] && modes+=("$mode")
      done < "$modes_file"
    fi
    monitors+=("$connector|${modes[*]}")
  done
  printf '%s\n' "${monitors[@]}"
}

pick_mode() {
  local connector="$1" modes_str="$2"
  local modes=() unique_res=()
  IFS=' ' read -ra modes <<< "$modes_str"

  if ((${#modes[@]} == 0)); then
    echo "   No modes detected for $connector. Using defaults."
    echo "1920x1080"
    return
  fi

  local seen=()
  for m in "${modes[@]}"; do
    local already=false
    for s in "${seen[@]}"; do
      [[ "$m" == "$s" ]] && already=true && break
    done
    $already || seen+=("$m")
  done

  if ((${#seen[@]} == 1)); then
    echo "${seen[0]}"
    return
  fi

  echo "   Available resolutions for $connector:"
  local i
  for i in "${!seen[@]}"; do
    echo "   [$((i+1))] ${seen[$i]}"
  done

  local choice
  while :; do
    read -rp "   Pick resolution [1-${#seen[@]}]: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#seen[@]})) && break
  done
  echo "${seen[$((choice-1))]}"
}

pick_ref() {
  local default="$1"
  local rates=(60 75 90 100 120 144 165 240)

  echo "   Available refresh rates:"
  local i
  for i in "${!rates[@]}"; do
    local tag=""
    [[ "${rates[$i]}" == "$default" ]] && tag=" (default)"
    echo "   [$((i+1))] ${rates[$i]}Hz$tag"
  done

  local choice
  while :; do
    read -rp "   Pick refresh rate [1-${#rates[@]}] or press Enter for ${default}Hz: " choice
    if [[ -z "$choice" ]]; then
      echo "$default"
      return
    fi
    [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#rates[@]})) && break
  done
  echo "${rates[$((choice-1))]}"
}

prompt_int() {
  local prompt="$1" default="$2"
  local val
  while :; do
    read -rp "   $prompt [$default]: " val
    val="${val:-$default}"
    [[ "$val" =~ ^[0-9]+$ ]] && break
  done
  echo "$val"
}

arrange_monitors() {
  local -n mons="$1"
  local count="${#mons[@]}"

  if ((count == 1)); then
    echo "single:${mons[0]%%|*}"
    return
  fi

  echo "   Multiple monitors detected."
  echo "   [1] Side-by-side (left-right)"
  echo "   [2] Single monitor only"
  local choice
  while :; do
    read -rp "   Choose layout [1-2]: " choice
    [[ "$choice" == 1 || "$choice" == 2 ]] && break
  done

  if ((choice == 2)); then
    echo "   Which monitor to use?"
    local i
    for i in "${!mons[@]}"; do
      echo "   [$((i+1))] ${mons[$i]%%|*}"
    done
    while :; do
      read -rp "   Pick [1-${#mons[@]}]: " choice
      [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#mons[@]})) && break
    done
    echo "single:${mons[$((choice-1))]%%|*}"
    return
  fi

  echo "side_by_side"
}

generate_hyprland_conf() {
  local -n mons="$1" conf="$2"
  local layout="$3"

  conf=$(<"$REPO_DIR/.config/hypr/hyprland.conf")

  if [[ "$layout" == single:* ]]; then
    local conn="${layout#single:}"
    conf="${conf//monitor = HDMI-A-2, 1920x1080@120, 0x0, 1/monitor = $conn, prefered, auto, 1}"
    conf="${conf//monitor = HDMI-A-1, 1920x1080@120, 1920x0, 1}"
    local i
    for i in $(seq 6 10); do
      conf="${conf//workspace = $i, monitor:HDMI-A-1, persistent:true/}"
    done
    for i in $(seq 1 10); do
      conf="${conf//workspace = $i, monitor:HDMI-A-2, persistent:true/workspace = $i, monitor:$conn, persistent:true}"
    done
    conf=$(sed -E '/^workspace = [0-9]+, monitor:HDMI-A-1, persistent:true$/d' <<< "$conf")
    return
  fi

  local primary_conn="${mons[0]%%|*}"
  local secondary_conn="${mons[1]%%|*}"
  local primary_res="${mons[0]#*|}"
  local secondary_res="${mons[1]#*|}"

  conf="${conf//HDMI-A-2/$primary_conn}"
  conf="${conf//HDMI-A-1/$secondary_conn}"
}

replace_connectors() {
  local -n mons="$1"
  local -n content="$2"
  local layout="$3"
  local template="$4"

  content=$(<"$template")

  if [[ "$layout" == single:* ]]; then
    local conn="${layout#single:}"
    content="${content//HDMI-A-2/$conn}"
    content="${content//HDMI-A-1/$conn}"
  else
    local primary_conn="${mons[0]%%|*}"
    local secondary_conn="${mons[1]%%|*}"
    content="${content//HDMI-A-2/$primary_conn}"
    content="${content//HDMI-A-1/$secondary_conn}"
  fi
}

main() {
  echo "=== Hyprland Monitor Setup ==="

  local detected
  detected=$(detect_monitors)

  if [[ -z "$detected" ]]; then
    echo "No connected monitors detected via sysfs."
    echo "Defaulting to current hyprland.conf as-is."
    exit 0
  fi

  local monitors=()
  while IFS= read -r line; do
    monitors+=("$line")
  done <<< "$detected"

  echo "Detected monitors:"
  local i
  for i in "${!monitors[@]}"; do
    local conn="${monitors[$i]%%|*}"
    local modes="${monitors[$i]#*|}"
    echo "  [$((i+1))] $conn — modes: ${modes:-auto}"
  done

  local -A chosen_res chosen_ref
  for m in "${monitors[@]}"; do
    local conn="${m%%|*}"
    local modes="${m#*|}"
    echo ""
    echo "Configuring $conn"
    local res
    res=$(pick_mode "$conn" "$modes")
    chosen_res["$conn"]="$res"
    local default_ref=60
    case "$res" in
      *@*) default_ref="${res##*@}" ;;
    esac
    local ref
    ref=$(pick_ref "$default_ref")
    chosen_ref["$conn"]="$ref"
  done

  echo ""
  local layout
  layout=$(arrange_monitors monitors)

  local updated_monitors=()
  for m in "${monitors[@]}"; do
    local conn="${m%%|*}"
    updated_monitors+=("$conn|${chosen_res[$conn]}@${chosen_ref[$conn]}")
  done

  local hypr_conf hyprpaper_user_conf hyprpaper_greetd_conf greetd_conf

  echo ""
  echo "Generating configs..."

  generate_hyprland_conf updated_monitors hypr_conf "$layout"
  replace_connectors updated_monitors hyprpaper_user_conf "$layout" "$REPO_DIR/.config/hypr/hyprpaper.conf"
  replace_connectors updated_monitors hyprpaper_greetd_conf "$layout" "$REPO_DIR/etc/hyprpaper/hyprpaper.conf"
  replace_connectors updated_monitors greetd_conf "$layout" "$REPO_DIR/etc/greetd/hyprland.conf"

  printf "%b\n" "$hypr_conf" > "$REPO_DIR/.config/hypr/hyprland.conf"
  printf "%b\n" "$hyprpaper_user_conf" > "$REPO_DIR/.config/hypr/hyprpaper.conf"
  printf "%b\n" "$hyprpaper_greetd_conf" > "$REPO_DIR/etc/hyprpaper/hyprpaper.conf"
  printf "%b\n" "$greetd_conf" > "$REPO_DIR/etc/greetd/hyprland.conf"

  echo ""
  echo "Updated:"
  echo "  .config/hypr/hyprland.conf"
  echo "  .config/hypr/hyprpaper.conf"
  echo "  etc/hyprpaper/hyprpaper.conf (greeter)"
  echo "  etc/greetd/hyprland.conf"
}

main "$@"
