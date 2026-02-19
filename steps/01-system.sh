#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "01 — System dependencies"

info "Updating package lists..."
sudo apt-get update -qq

BASE_PKGS=(
    # Build essentials
    build-essential curl wget git unzip zip tar gnupg ca-certificates
    software-properties-common apt-transport-https
    # Shell
    zsh
    # Core tools (some may be overridden by newer versions below)
    fzf autojump
    # Network / HTTP
    httpie
    # JSON / YAML
    jq
    # System tools
    btop tmux
    # Misc
    xclip xdotool duf
    # Dependencies for tools installed later
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    # Redis CLI
    redis-tools
    # Python base
    python3-pip python3-venv python3-dev pipx
)

info "Installing base packages..."
sudo apt-get install -y "${BASE_PKGS[@]}" -qq 2>&1 | grep -E "^(Err|W:)" || true
success "Base packages installed"

# tldr (Node-based; use the Go/Rust version if available, else apt)
if ! has tldr; then
    info "Installing tldr..."
    if has pipx; then
        pipx install tldr 2>/dev/null || sudo apt-get install -y tldr -qq || true
    fi
fi

success "System dependencies complete"
