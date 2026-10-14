#!/usr/bin/env bash
#
# Interactive picker for the two TransArch fastfetch looks.
# Only relies on: bash, coreutils, fastfetch, pacman (all present on any
# standard Arch install running fastfetch already). No network calls, no
# telemetry - the only thing this reads is local terminal env vars, and the
# only thing it writes is a one-line cache file recording which image mode
# worked, so you don't have to redo this every time.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
LOOKS_DIR="$SCRIPT_DIR/looks"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/transarch-fastfetch-logo-type"

BOLD="$(tput bold 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"
CYAN="$(tput setaf 6 2>/dev/null || true)"
GREEN="$(tput setaf 2 2>/dev/null || true)"
YELLOW="$(tput setaf 3 2>/dev/null || true)"

# Candidate image protocols to cycle through, in the order most terminals
# succeed with. Format: "logo-type:width:height" (width/height blank if unused).
CANDIDATES=("kitty-direct::" "iterm:25:25" "sixel::" "auto::")

LOGO_TYPE=""
LOGO_WIDTH=""
LOGO_HEIGHT=""

ensure_fastfetch() {
    if command -v fastfetch >/dev/null 2>&1; then
        return
    fi

    echo "${YELLOW}fastfetch is not installed.${RESET}"
    read -r -p "Install it now with 'sudo pacman -S fastfetch'? [y/N] " reply
    case "$reply" in
        [yY][eE][sS]|[yY])
            sudo pacman -S --needed fastfetch
            ;;
        *)
            echo "fastfetch is required to preview or use these configs. Exiting."
            exit 1
            ;;
    esac
}

# Best-effort guess from local terminal env vars - nothing here leaves your machine.
guess_logo_type() {
    if [[ -n "${KITTY_WINDOW_ID:-}" || "${TERM:-}" == "xterm-kitty" || -n "${WEZTERM_EXECUTABLE:-}" || "${TERM:-}" == "xterm-ghostty" ]]; then
        LOGO_TYPE="kitty-direct"; LOGO_WIDTH=""; LOGO_HEIGHT=""
    elif [[ -n "${KONSOLE_VERSION:-}" || -n "${ITERM_SESSION_ID:-}" ]]; then
        LOGO_TYPE="iterm"; LOGO_WIDTH="25"; LOGO_HEIGHT="25"
    else
        LOGO_TYPE="auto"; LOGO_WIDTH=""; LOGO_HEIGHT=""
    fi
}

load_or_guess_logo_type() {
    if [[ -f "$CACHE_FILE" ]]; then
        IFS=':' read -r LOGO_TYPE LOGO_WIDTH LOGO_HEIGHT < "$CACHE_FILE"
    else
        guess_logo_type
    fi
}

save_logo_type() {
    mkdir -p "$(dirname -- "$CACHE_FILE")"
    printf '%s:%s:%s\n' "$LOGO_TYPE" "$LOGO_WIDTH" "$LOGO_HEIGHT" > "$CACHE_FILE"
}

# Advance to the next untried candidate. Returns 1 once the list is exhausted.
next_candidate() {
    local current="$LOGO_TYPE:$LOGO_WIDTH:$LOGO_HEIGHT"
    local found=0
    local c
    for c in "${CANDIDATES[@]}"; do
        if [[ $found -eq 1 ]]; then
            IFS=':' read -r LOGO_TYPE LOGO_WIDTH LOGO_HEIGHT <<< "$c"
            return 0
        fi
        [[ "$c" == "$current" ]] && found=1
    done
    return 1
}

run_fastfetch() {
    local name="$1"

    clear
    echo "${BOLD}${CYAN}== ${name} ==${RESET} (trying: ${LOGO_TYPE})"
    echo
    local args=(--config "$LOOKS_DIR/$name/config.jsonc" --file "$LOOKS_DIR/$name/logo.png")
    if [[ "$LOGO_TYPE" != "auto" ]]; then
        args+=(--logo-type "$LOGO_TYPE")
        [[ -n "$LOGO_WIDTH" ]] && args+=(--logo-width "$LOGO_WIDTH")
        [[ -n "$LOGO_HEIGHT" ]] && args+=(--logo-height "$LOGO_HEIGHT")
    fi
    fastfetch "${args[@]}"
}

# Preview a look, auto-cycling render modes until one is confirmed to work
# (or we run out, in which case we fall back gracefully to plain text).
preview() {
    local name="$1"

    load_or_guess_logo_type

    while true; do
        run_fastfetch "$name"
        echo
        read -r -p "Did the flag logo actually show up (not text/garbled)? [Y/n] " ok
        case "$ok" in
            [nN]*)
                if next_candidate; then
                    echo "Trying a different rendering mode for your terminal..."
                    sleep 1
                else
                    echo
                    echo "${YELLOW}No image mode worked in this terminal.${RESET} That's fine -"
                    echo "fastfetch will just show a plain-text logo; everything else"
                    echo "(OS, CPU, GPU, etc.) still displays correctly."
                    LOGO_TYPE="auto"; LOGO_WIDTH=""; LOGO_HEIGHT=""
                    save_logo_type
                    read -r -p "Press Enter to continue..." _
                    return
                fi
                ;;
            *)
                echo "${GREEN}Great, remembering that for next time.${RESET}"
                save_logo_type
                read -r -p "Press Enter to continue..." _
                return
                ;;
        esac
    done
}

# Bake the confirmed logo type into the installed config, so plain `fastfetch`
# (no flags) renders correctly forever after - no need to rerun this script.
build_logo_block() {
    local path="$1"
    if [[ "$LOGO_TYPE" == "auto" || -z "$LOGO_TYPE" ]]; then
        printf '"logo": "%s"' "$path"
        return
    fi
    local block
    block="\"logo\": {
        \"source\": \"$path\",
        \"type\": \"$LOGO_TYPE\""
    [[ -n "$LOGO_WIDTH" ]] && block+=",
        \"width\": $LOGO_WIDTH"
    [[ -n "$LOGO_HEIGHT" ]] && block+=",
        \"height\": $LOGO_HEIGHT"
    block+="
    }"
    printf '%s' "$block"
}

# Looks are folders under looks/ holding config.jsonc + logo.png.
list_looks() {
    local d
    for d in "$LOOKS_DIR"/*/; do
        [[ -f "$d/config.jsonc" && -f "$d/logo.png" ]] && basename -- "$d"
    done
}

valid_look() {
    [[ -n "$1" && -f "$LOOKS_DIR/$1/config.jsonc" && -f "$LOOKS_DIR/$1/logo.png" ]]
}

install_look() {
    local name="$1"
    local target_logo_path="~/.config/fastfetch/logos/$name.png"

    load_or_guess_logo_type
    mkdir -p "$TARGET_DIR/logos"

    if [[ -f "$TARGET_DIR/config.jsonc" ]]; then
        local backup
        backup="$TARGET_DIR/config.jsonc.bak-$(date +%Y%m%d-%H%M%S)"
        cp "$TARGET_DIR/config.jsonc" "$backup"
        echo "Backed up existing config to ${backup}"
    fi

    local content old new
    content="$(<"$LOOKS_DIR/$name/config.jsonc")"
    old="\"logo\": \"$target_logo_path\""
    new="$(build_logo_block "$target_logo_path")"
    content="${content//$old/$new}"
    printf '%s\n' "$content" > "$TARGET_DIR/config.jsonc"
    cp "$LOOKS_DIR/$name/logo.png" "$TARGET_DIR/logos/$name.png"
    echo "${GREEN}${name} look installed to ${TARGET_DIR}${RESET}"
}

# Removes the installed config and bundled logos. Backups are left alone.
uninstall_looks() {
    local name
    rm -f "$TARGET_DIR/config.jsonc"
    while read -r name; do
        rm -f "$TARGET_DIR/logos/$name.png"
    done < <(list_looks)
    rmdir "$TARGET_DIR/logos" 2>/dev/null || true
    echo "Removed installed TransArch config and logos from ${TARGET_DIR}"
}

main_menu() {
    local looks=() name choice i
    while read -r name; do looks+=("$name"); done < <(list_looks)
    local n=${#looks[@]}

    while true; do
        clear
        echo "${BOLD}TransArch fastfetch - choose your look${RESET}"
        echo
        for i in "${!looks[@]}"; do
            echo "  $((i + 1))) Preview ${looks[$i]}"
        done
        for i in "${!looks[@]}"; do
            echo "  $((n + i + 1))) Install ${looks[$i]}"
        done
        echo "  $((2 * n + 1))) Forget saved render mode (if you switched terminals)"
        echo "  $((2 * n + 2))) Quit"
        echo
        read -r -p "Choice [1-$((2 * n + 2))]: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= n )); then
            preview "${looks[choice - 1]}"
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > n && choice <= 2 * n )); then
            install_look "${looks[choice - n - 1]}"
            read -r -p "Press Enter to continue..." _
        elif [[ "$choice" == "$((2 * n + 1))" ]]; then
            rm -f "$CACHE_FILE"
            echo "Forgotten. It'll re-detect next time you preview."
            sleep 1
        elif [[ "$choice" == "$((2 * n + 2))" ]]; then
            echo "Bye!"; exit 0
        else
            echo "Invalid choice."; sleep 1
        fi
    done
}

usage() {
    cat <<USAGE
Usage: ${0##*/} [--look NAME | --list | --uninstall | --help]

  (no args)      interactive menu
  --look NAME    install a look without prompts
  --list         list available looks
  --uninstall    remove the installed config and logos
USAGE
}

case "${1:-}" in
    --list)
        list_looks
        ;;
    --help|-h)
        usage
        ;;
    --uninstall)
        uninstall_looks
        ;;
    --look)
        if ! valid_look "${2:-}"; then
            echo "Unknown look '${2:-}'. Available:" >&2
            list_looks >&2
            exit 1
        fi
        install_look "$2"
        ;;
    "")
        ensure_fastfetch
        main_menu
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac
