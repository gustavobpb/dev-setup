#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
#  Dev Terminal Setup — Ubuntu 24.04
#  Run: bash ~/dev-setup/setup.sh [--profiles sre,dba,python,frontend,backend]
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

# ── Parse arguments ───────────────────────────────────────────────────────────
INSTALL_PROFILES=()
INSTALL_ALL_PROFILES=false
SKIP_NEOVIM=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --profiles)
            IFS=',' read -r -a INSTALL_PROFILES <<< "$2"
            shift 2 ;;
        --all-profiles)
            INSTALL_ALL_PROFILES=true
            shift ;;
        --skip-neovim)
            SKIP_NEOVIM=true
            shift ;;
        --reset)
            rm -f "${HOME}/.dev-setup.progress"
            info "Progress reset. Will start from the beginning."
            shift ;;
        --help|-h)
            echo "Usage: bash setup.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --profiles sre,dba,python,frontend,backend  Install specific profile tools"
            echo "  --all-profiles                               Install all profile tools"
            echo "  --skip-neovim                               Skip Neovim/LazyVim installation"
            echo "  --reset                                     Clear progress and start fresh"
            echo ""
            echo "Example: bash setup.sh --profiles python,frontend"
            exit 0 ;;
        *) warn "Unknown argument: $1"; shift ;;
    esac
done

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     Professional Dev Terminal Setup            ║${NC}"
echo -e "${BOLD}${CYAN}║     Ubuntu 24.04 · Ghostty · Zsh · P10k       ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""
info "This script requires sudo for some steps."
info "You will be prompted for your password when needed."
if [[ -f "${HOME}/.dev-setup.progress" ]]; then
    echo ""
    warn "Resuming from a previous run — completed steps will be skipped."
    warn "Run with --reset to start fresh."
fi
echo ""

# ── Sudo keepalive (refresh sudo ticket every 60s) ────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT

# ── Step runner ───────────────────────────────────────────────────────────────
run_step() {
    local script="$1"
    local name="$2"
    local confirm_msg="${3:-}"
    if is_step_done "$script"; then
        info "Already completed, skipping: $name"
        return 0
    fi
    [[ -n "$confirm_msg" ]] && confirm_step "$confirm_msg"
    if [[ -f "$SCRIPT_DIR/steps/$script" ]]; then
        bash "$SCRIPT_DIR/steps/$script"
        step_done "$script"
        success "Step complete: $name"
    else
        error "Step script not found: $script"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 1: Base System"
# ─────────────────────────────────────────────────────────────────────────────
run_step "01-system.sh" "System dependencies" \
    "Installing system packages (curl, wget, zsh, jq, btop, tmux, etc.)"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 2: Fonts"
# ─────────────────────────────────────────────────────────────────────────────
run_step "02-fonts.sh" "Nerd Fonts" \
    "Downloading JetBrains Mono Nerd Font"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 3: Ghostty Terminal"
# ─────────────────────────────────────────────────────────────────────────────
run_step "03-ghostty.sh" "Ghostty" \
    "Installing Ghostty + Catppuccin Mocha config"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 4: Zsh + Oh My Zsh + Powerlevel10k"
# ─────────────────────────────────────────────────────────────────────────────
run_step "04-zsh.sh" "Zsh stack" \
    "Installing Zsh, Oh My Zsh, Powerlevel10k theme, and all plugins"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 5: CLI Tools"
# ─────────────────────────────────────────────────────────────────────────────
run_step "05-tools.sh" "CLI tools" \
    "Installing eza, bat, ripgrep, fd, fzf, zoxide, delta, btop, tldr, jq, yq, httpie, duf, dust"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 6: Tmux + Oh My Tmux"
# ─────────────────────────────────────────────────────────────────────────────
run_step "06-tmux.sh" "Tmux" \
    "Installing Tmux, Oh My Tmux, TPM, and plugins (tmux-resurrect, tmux-continuum)"

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 7: Neovim + LazyVim"
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$SKIP_NEOVIM" == "false" ]]; then
    run_step "07-neovim.sh" "Neovim" \
        "Installing Neovim (stable) + LazyVim + LSP configs"
else
    warn "Skipping Neovim (--skip-neovim)"
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 8: Profile-Specific Tools"
# ─────────────────────────────────────────────────────────────────────────────

PROFILE_SCRIPTS=(
    "sre:08-profile-sre.sh:SRE/DevOps (kubectl, helm, k9s, terraform, aws, gcloud, docker, flux)"
    "dba:09-profile-dba.sh:DBA (pgcli, mycli, litecli, usql, mongosh, dbeaver)"
    "python:10-profile-python.sh:Python (pyenv, uv, poetry, ruff, mypy, ipython, jupyter)"
    "frontend:11-profile-frontend.sh:Frontend (nvm, Node LTS, pnpm, bun, vercel, netlify)"
    "backend:12-profile-backend.sh:Backend (asdf, Go, Rust, Java, maven, gradle, k6, wrk)"
)

should_install_profile() {
    local profile="$1"
    if [[ "$INSTALL_ALL_PROFILES" == "true" ]]; then
        return 0
    fi
    for p in "${INSTALL_PROFILES[@]:-}"; do
        [[ "$p" == "$profile" ]] && return 0
    done
    return 1
}

if [[ ${#INSTALL_PROFILES[@]} -eq 0 ]] && [[ "$INSTALL_ALL_PROFILES" == "false" ]]; then
    echo ""
    info "No profiles specified. Select profiles to install:"
    echo ""
    echo "  Available profiles:"
    for entry in "${PROFILE_SCRIPTS[@]}"; do
        local pname="${entry%%:*}"
        local pdesc="${entry##*:}"
        echo "    [$pname]  $pdesc"
    done
    echo ""
    echo "  Options:"
    echo "    1) Select specific profiles"
    echo "    2) Install all profiles"
    echo "    3) Skip profile tools (install base only)"
    echo ""
    read -r -p "  Your choice [1/2/3]: " choice
    case "$choice" in
        1)
            echo "  Enter profile names (comma-separated, e.g.: python,frontend):"
            read -r -p "  Profiles: " profile_input
            IFS=',' read -r -a INSTALL_PROFILES <<< "$profile_input"
            ;;
        2) INSTALL_ALL_PROFILES=true ;;
        3) info "Skipping all profile tools" ;;
        *) warn "Invalid choice, skipping profiles" ;;
    esac
fi

for entry in "${PROFILE_SCRIPTS[@]}"; do
    profile="${entry%%:*}"
    rest="${entry#*:}"
    script="${rest%%:*}"
    desc="${rest##*:}"

    if should_install_profile "$profile"; then
        run_step "$script" "$desc" "Installing $desc"
    else
        info "Skipping profile: $profile (not selected)"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 9: Git delta configuration"
# ─────────────────────────────────────────────────────────────────────────────
if is_step_done "09-git-delta-config"; then
    info "Already completed, skipping: Git delta configuration"
elif command -v delta &>/dev/null; then
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global delta.syntax-theme "Catppuccin Mocha"
    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"
    step_done "09-git-delta-config"
    success "Git delta configured"
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Phase 10: bat Catppuccin theme"
# ─────────────────────────────────────────────────────────────────────────────
if is_step_done "10-bat-theme"; then
    info "Already completed, skipping: bat Catppuccin theme"
else
    BAT_THEMES_DIR="$(bat --config-dir 2>/dev/null)/themes"
    if [[ -n "$BAT_THEMES_DIR" ]] && ! ls "$BAT_THEMES_DIR"/*catppuccin* &>/dev/null; then
        mkdir -p "$BAT_THEMES_DIR"
        wget -q --show-progress -O "$BAT_THEMES_DIR/Catppuccin Mocha.tmTheme" \
            "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" 2>/dev/null || true
        bat cache --build 2>/dev/null || true
        success "bat Catppuccin Mocha theme installed"
    fi
    step_done "10-bat-theme"
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Final: Summary"
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║             Installation Complete!             ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

print_version() {
    local name="$1"
    local cmd="$2"
    local version
    version=$(eval "$cmd" 2>/dev/null | head -1 || echo "not installed")
    printf "  %-22s %s\n" "$name" "$version"
}

echo -e "${BOLD}Installed versions:${NC}"
echo "  ──────────────────────────────────────────"
print_version "zsh"          "zsh --version"
print_version "ghostty"      "ghostty --version"
print_version "nvim"         "nvim --version | head -1"
print_version "tmux"         "tmux -V"
print_version "fzf"          "fzf --version"
print_version "eza"          "eza --version | head -1"
print_version "bat"          "bat --version"
print_version "rg"           "rg --version | head -1"
print_version "fd"           "fd --version"
print_version "zoxide"       "zoxide --version"
print_version "delta"        "delta --version"
print_version "btop"         "btop --version 2>/dev/null || echo 'installed'"
print_version "jq"           "jq --version"
print_version "yq"           "yq --version"
print_version "tldr"         "tldr --version 2>/dev/null || echo 'installed'"
print_version "httpie"       "http --version 2>/dev/null || http --version"
print_version "duf"          "duf --version 2>/dev/null || echo 'installed'"
print_version "dust"         "dust --version 2>/dev/null || echo 'installed'"
echo "  ──────────────────────────────────────────"
echo ""

echo -e "${BOLD}Next steps:${NC}"
echo "  1. Start a new shell:     exec zsh"
echo "  2. Load a dev profile:    switch-profile  (or alias: sp)"
echo "  3. Configure tmux:        tmux then prefix+I to install plugins"
echo "  4. Start Ghostty:         ghostty"
echo "  5. Run Neovim once:       nvim  (LazyVim will auto-install plugins)"
echo "  6. Customize p10k:        p10k configure  (optional, config already applied)"
echo ""
echo -e "  Profile files:  ${CYAN}~/.zsh/profiles/{sre,dba,python,frontend,backend}.zsh${NC}"
echo -e "  Main config:    ${CYAN}~/.zshrc${NC}"
echo -e "  Ghostty config: ${CYAN}~/.config/ghostty/config${NC}"
echo -e "  Tmux config:    ${CYAN}~/.tmux.conf.local${NC}"
echo ""
echo -e "  ${YELLOW}Note: Log out and back in for shell change (chsh) to take effect.${NC}"
echo -e "  ${YELLOW}Note: If in docker group, re-login for docker access without sudo.${NC}"
echo ""
