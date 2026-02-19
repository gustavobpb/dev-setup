#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "11a — Frontend Developer Profile Tools"

# ── nvm ───────────────────────────────────────────────────────────────────────
NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
    success "nvm already installed"
else
    info "Installing nvm..."
    NVM_VER=$(github_latest_url "nvm-sh/nvm" "\.zip$" | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
    [[ -z "$NVM_VER" ]] && NVM_VER="v0.40.1"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh" | bash
    success "nvm installed"
fi

# Load nvm for this session (nvm uses unbound variables internally, disable -u around it)
export NVM_DIR="$HOME/.nvm"
set +u
# shellcheck source=/dev/null
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
set -u

# ── Node LTS ──────────────────────────────────────────────────────────────────
if has nvm; then
    if ! nvm ls --no-colors 2>/dev/null | grep -q "lts/\|v2[0-9]"; then
        info "Installing Node.js LTS..."
        set +u
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        set -u
        success "Node LTS installed: $(node --version)"
    else
        success "Node.js LTS already installed"
    fi
fi

# ── pnpm ──────────────────────────────────────────────────────────────────────
if ! has pnpm; then
    info "Installing pnpm..."
    npm install -g pnpm 2>/dev/null || curl -fsSL https://get.pnpm.io/install.sh | sh
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    success "pnpm installed"
else
    success "pnpm already installed: $(pnpm --version)"
fi

# ── bun ───────────────────────────────────────────────────────────────────────
if ! has bun; then
    info "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    success "bun installed: $(bun --version 2>/dev/null || echo 'ok')"
else
    success "bun already installed: $(bun --version)"
fi

# ── Global npm/pnpm packages ──────────────────────────────────────────────────
GLOBAL_PKGS=(
    npm-check-updates
    prettier
    eslint
)
if has pnpm; then
    for pkg in "${GLOBAL_PKGS[@]}"; do
        if ! pnpm list -g "$pkg" &>/dev/null; then
            info "  pnpm add -g $pkg..."
            pnpm add -g "$pkg" 2>/dev/null || npm install -g "$pkg" 2>/dev/null || true
        fi
    done
fi

# Vercel and Netlify CLIs (large installs, optional)
if has pnpm; then
    has vercel || pnpm add -g vercel 2>/dev/null && success "vercel CLI installed" || true
    has netlify || pnpm add -g netlify-cli 2>/dev/null && success "netlify CLI installed" || true
fi

success "Frontend profile tools installed"
