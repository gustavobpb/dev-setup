#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "02 — Nerd Fonts (JetBrains Mono)"

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNF"

if fc-list | grep -qi "JetBrainsMono Nerd"; then
    success "JetBrains Mono Nerd Font already installed"
    exit 0
fi

mkdir -p "$FONT_DIR"
info "Downloading JetBrains Mono Nerd Font..."
FONT_URL=$(github_latest_url "ryanoasis/nerd-fonts" "JetBrainsMono\.zip")
if [[ -z "$FONT_URL" ]]; then
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
fi

TMP_ZIP=$(mktemp /tmp/JetBrainsMonoNF.XXXXXX.zip)
wget -q --show-progress -O "$TMP_ZIP" "$FONT_URL"
unzip -o -q "$TMP_ZIP" -d "$FONT_DIR" '*.ttf' || unzip -o -q "$TMP_ZIP" -d "$FONT_DIR"
rm -f "$TMP_ZIP"

info "Refreshing font cache..."
fc-cache -fv "$FONT_DIR" &>/dev/null
success "JetBrains Mono Nerd Font installed"
