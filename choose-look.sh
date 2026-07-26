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
    local label="$1" config="$2" logo_file="$3"

    clear
    echo "${BOLD}${CYAN}== ${label} ==${RESET} (trying: ${LOGO_TYPE})"
    echo
    local args=(--config "$config" --file "$SCRIPT_DIR/logos/$logo_file")
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
    local label="$1" config="$2" logo_file="$3"

    load_or_guess_logo_type

    while true; do
        run_fastfetch "$label" "$config" "$logo_file"
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

install_look() {
    local src_config="$1" logo_file="$2" target_logo_path="$3"

    load_or_guess_logo_type
    mkdir -p "$TARGET_DIR/logos"

    local content old new
    content="$(<"$src_config")"
    old="\"logo\": \"$target_logo_path\""
    new="$(build_logo_block "$target_logo_path")"
    content="${content//$old/$new}"
    printf '%s\n' "$content" > "$TARGET_DIR/config.jsonc"
    cp "$SCRIPT_DIR/logos/$logo_file" "$TARGET_DIR/logos/$logo_file"
}

install_default() {
    install_look "$SCRIPT_DIR/config.jsonc" "trans_default.png" "~/.config/fastfetch/logos/trans_default.png"
    echo "${GREEN}Default look installed to ${TARGET_DIR}${RESET}"
}

install_customized() {
    install_look "$SCRIPT_DIR/config-customized.jsonc" "trans_customized.png" "~/.config/fastfetch/logos/trans_customized.png"
    echo "${GREEN}Customized look installed to ${TARGET_DIR}${RESET}"
}

main_menu() {
    while true; do
        clear
        echo "${BOLD}TransArch fastfetch - choose your look${RESET}"
        echo
        echo "  1) Preview default look"
        echo "  2) Preview customized look"
        echo "  3) Install default look"
        echo "  4) Install customized look"
        echo "  5) Forget saved render mode (if you switched terminals)"
        echo "  6) Quit"
        echo
        read -r -p "Choice [1-6]: " choice

        case "$choice" in
            1) preview "Default look" "$SCRIPT_DIR/config.jsonc" "trans_default.png" ;;
            2) preview "Customized look" "$SCRIPT_DIR/config-customized.jsonc" "trans_customized.png" ;;
            3)
                install_default
                read -r -p "Press Enter to continue..." _
                ;;
            4)
                install_customized
                read -r -p "Press Enter to continue..." _
                ;;
            5)
                rm -f "$CACHE_FILE"
                echo "Forgotten. It'll re-detect next time you preview."
                sleep 1
                ;;
            6) echo "Bye!"; exit 0 ;;
            *) echo "Invalid choice."; sleep 1 ;;
        esac
    done
}

ensure_fastfetch
main_menu
