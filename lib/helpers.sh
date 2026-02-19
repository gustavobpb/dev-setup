#!/usr/bin/env bash
# Common helper functions

# Check if a command exists
has() { command -v "$1" &>/dev/null; }

# Install apt package if not already installed
apt_install() {
    local pkg="$1"
    if dpkg -s "$pkg" &>/dev/null; then
        info "  apt: $pkg already installed"
    else
        info "  apt: installing $pkg..."
        sudo apt-get install -y "$pkg" -qq 2>&1 | grep -E "^(Err|W:)" || true
        success "  apt: $pkg installed"
    fi
}

# Run a command only if target binary is missing
install_if_missing() {
    local cmd="$1"
    local desc="$2"
    shift 2
    if has "$cmd"; then
        info "  $desc already installed ($(command -v "$cmd"))"
    else
        info "  Installing $desc..."
        "$@"
        success "  $desc installed"
    fi
}

# Download latest GitHub release asset matching a pattern
github_latest_url() {
    local repo="$1"   # e.g. "cli/cli"
    local pattern="$2" # grep-E pattern for asset name
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null \
        | grep "browser_download_url" \
        | grep -E "$pattern" \
        | head -1 \
        | cut -d '"' -f 4 || true
}

# Confirm a step before proceeding
confirm_step() {
    local msg="$1"
    echo -e "\n${BOLD}${YELLOW}[CONFIRM]${NC} $msg"
    read -r -p "  Press Enter to continue or Ctrl+C to abort... "
}

# ── Step progress tracking ─────────────────────────────────────────────────────
PROGRESS_FILE="${HOME}/.dev-setup.progress"

step_done() {
    echo "$1" >> "$PROGRESS_FILE"
}

is_step_done() {
    [[ -f "$PROGRESS_FILE" ]] && grep -qxF "$1" "$PROGRESS_FILE"
}

# Add a line to a file if not already present
add_line_if_missing() {
    local file="$1"
    local line="$2"
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}
