#!/usr/bin/env bash
#
# Interactive picker for the two TransArch fastfetch looks.
# Only relies on: bash, coreutils, fastfetch, pacman (all present on any
# standard Arch install running fastfetch already).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"

BOLD="$(tput bold 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"
CYAN="$(tput setaf 6 2>/dev/null || true)"
GREEN="$(tput setaf 2 2>/dev/null || true)"
YELLOW="$(tput setaf 3 2>/dev/null || true)"

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

preview() {
    local label="$1"
    local config="$2"

    clear
    echo "${BOLD}${CYAN}== ${label} ==${RESET}"
    echo
    # Run from the repo dir so relative logo paths resolve correctly.
    (cd "$SCRIPT_DIR" && fastfetch --config "$config")
    echo
    read -r -p "Press Enter to continue..." _
}

install_default() {
    mkdir -p "$TARGET_DIR/Logo"
    cp "$SCRIPT_DIR/config.jsonc" "$TARGET_DIR/config.jsonc"
    cp "$SCRIPT_DIR/Logo/trans_arch.png" "$TARGET_DIR/Logo/trans_arch.png"
    echo "${GREEN}Default look installed to ${TARGET_DIR}${RESET}"
}

install_customized() {
    mkdir -p "$TARGET_DIR/pngs"
    cp "$SCRIPT_DIR/config-customized.jsonc" "$TARGET_DIR/config.jsonc"
    cp "$SCRIPT_DIR"/pngs/*.png "$TARGET_DIR/pngs/"
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
        echo "  5) Quit"
        echo
        read -r -p "Choice [1-5]: " choice

        case "$choice" in
            1) preview "Default look" "$SCRIPT_DIR/config.jsonc" ;;
            2) preview "Customized look" "$SCRIPT_DIR/config-customized.jsonc" ;;
            3)
                install_default
                read -r -p "Press Enter to continue..." _
                ;;
            4)
                install_customized
                read -r -p "Press Enter to continue..." _
                ;;
            5) echo "Bye!"; exit 0 ;;
            *) echo "Invalid choice."; sleep 1 ;;
        esac
    done
}

ensure_fastfetch
main_menu
