#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "05 — Essential CLI Tools"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# ── eza (modern ls) ────────────────────────────────────────────────────────────
if ! has eza; then
    info "Installing eza..."
    # Official repo for Ubuntu
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq
    sudo apt-get install -y eza -qq
    success "eza installed: $(eza --version | head -1)"
else
    success "eza already installed"
fi

# ── bat (cat replacement) ──────────────────────────────────────────────────────
if ! has bat && ! has batcat; then
    info "Installing bat..."
    BAT_URL=$(github_latest_url "sharkdp/bat" "x86_64-unknown-linux-gnu\.tar\.gz$")
    [[ -z "$BAT_URL" ]] && BAT_URL="https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz"
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/bat.tar.gz" "$BAT_URL"
    tar -xzf "$TMP/bat.tar.gz" -C "$TMP"
    cp "$TMP"/bat-*/bat "$LOCAL_BIN/"
    rm -rf "$TMP"
    success "bat installed: $(bat --version)"
else
    # Ubuntu installs as batcat, create symlink
    if has batcat && ! has bat; then
        ln -sf "$(which batcat)" "$LOCAL_BIN/bat"
        success "bat symlink created → batcat"
    else
        success "bat already installed"
    fi
fi

# ── ripgrep ────────────────────────────────────────────────────────────────────
if ! has rg; then
    info "Installing ripgrep..."
    RG_URL=$(github_latest_url "BurntSushi/ripgrep" "x86_64-unknown-linux-musl\.tar\.gz$")
    [[ -z "$RG_URL" ]] && RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/rg.tar.gz" "$RG_URL"
    tar -xzf "$TMP/rg.tar.gz" -C "$TMP"
    cp "$TMP"/ripgrep-*/rg "$LOCAL_BIN/"
    rm -rf "$TMP"
    success "ripgrep installed: $(rg --version | head -1)"
else
    success "ripgrep already installed"
fi

# ── fd (find replacement) ──────────────────────────────────────────────────────
if ! has fd && ! has fdfind; then
    info "Installing fd..."
    FD_URL=$(github_latest_url "sharkdp/fd" "x86_64-unknown-linux-gnu\.tar\.gz$")
    [[ -z "$FD_URL" ]] && FD_URL="https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz"
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/fd.tar.gz" "$FD_URL"
    tar -xzf "$TMP/fd.tar.gz" -C "$TMP"
    cp "$TMP"/fd-*/fd "$LOCAL_BIN/"
    rm -rf "$TMP"
    success "fd installed: $(fd --version)"
else
    if has fdfind && ! has fd; then
        ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
        success "fd symlink created → fdfind"
    else
        success "fd already installed"
    fi
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if ! has fzf; then
    info "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish --key-bindings --completion --no-update-rc
    success "fzf installed"
else
    success "fzf already installed: $(fzf --version)"
fi

# ── zoxide (smart cd) ─────────────────────────────────────────────────────────
if ! has zoxide; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    success "zoxide installed"
else
    success "zoxide already installed: $(zoxide --version)"
fi

# ── delta (git diff) ──────────────────────────────────────────────────────────
if ! has delta; then
    info "Installing delta..."
    DELTA_URL=$(github_latest_url "dandavison/delta" "x86_64-unknown-linux-gnu\.tar\.gz$")
    [[ -z "$DELTA_URL" ]] && DELTA_URL="https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz"
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/delta.tar.gz" "$DELTA_URL"
    tar -xzf "$TMP/delta.tar.gz" -C "$TMP"
    cp "$TMP"/delta-*/delta "$LOCAL_BIN/"
    rm -rf "$TMP"
    success "delta installed: $(delta --version)"
else
    success "delta already installed"
fi

# ── btop ──────────────────────────────────────────────────────────────────────
if ! has btop; then
    info "Installing btop..."
    sudo apt-get install -y btop -qq 2>/dev/null || {
        BTOP_URL=$(github_latest_url "aristocratos/btop" "x86_64-linux-musl\.tbz$")
        if [[ -n "$BTOP_URL" ]]; then
            TMP=$(mktemp -d)
            wget -q --show-progress -O "$TMP/btop.tbz" "$BTOP_URL"
            tar -xjf "$TMP/btop.tbz" -C "$TMP"
            cp "$TMP/btop/bin/btop" "$LOCAL_BIN/"
            rm -rf "$TMP"
        fi
    }
    success "btop installed"
else
    success "btop already installed"
fi

# ── tldr ──────────────────────────────────────────────────────────────────────
if ! has tldr; then
    info "Installing tldr (tealdeer)..."
    TLDR_URL=$(github_latest_url "dbrgn/tealdeer" "tealdeer-linux-x86_64-musl$")
    if [[ -n "$TLDR_URL" ]]; then
        wget -q --show-progress -O "$LOCAL_BIN/tldr" "$TLDR_URL"
        chmod +x "$LOCAL_BIN/tldr"
        "$LOCAL_BIN/tldr" --update &>/dev/null || true
        success "tldr (tealdeer) installed"
    else
        sudo apt-get install -y tldr -qq 2>/dev/null || pipx install tldr || warn "Could not install tldr"
    fi
else
    success "tldr already installed"
fi

# ── jq ────────────────────────────────────────────────────────────────────────
if ! has jq; then
    sudo apt-get install -y jq -qq
fi
success "jq: $(jq --version)"

# ── yq ────────────────────────────────────────────────────────────────────────
if ! has yq; then
    info "Installing yq..."
    YQ_URL=$(github_latest_url "mikefarah/yq" "yq_linux_amd64$")
    [[ -z "$YQ_URL" ]] && YQ_URL="https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64"
    wget -q --show-progress -O "$LOCAL_BIN/yq" "$YQ_URL"
    chmod +x "$LOCAL_BIN/yq"
    success "yq installed: $(yq --version)"
else
    success "yq already installed"
fi

# ── httpie ────────────────────────────────────────────────────────────────────
if ! has http && ! has httpie; then
    sudo apt-get install -y httpie -qq 2>/dev/null || pipx install httpie || true
fi
has http && success "httpie installed" || warn "httpie not found in PATH"

# ── duf (disk usage) ──────────────────────────────────────────────────────────
if ! has duf; then
    info "Installing duf..."
    DUF_URL=$(github_latest_url "muesli/duf" "linux_amd64\.deb$")
    if [[ -n "$DUF_URL" ]]; then
        TMP_DEB=$(mktemp /tmp/duf.XXXXXX.deb)
        wget -q --show-progress -O "$TMP_DEB" "$DUF_URL"
        sudo dpkg -i "$TMP_DEB" && rm -f "$TMP_DEB"
    else
        sudo apt-get install -y duf -qq || warn "duf not available"
    fi
else
    success "duf already installed"
fi

# ── dust (du replacement) ─────────────────────────────────────────────────────
if ! has dust; then
    info "Installing dust..."
    DUST_URL=$(github_latest_url "bootandy/dust" "x86_64-unknown-linux-musl\.tar\.gz$")
    if [[ -n "$DUST_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q --show-progress -O "$TMP/dust.tar.gz" "$DUST_URL"
        tar -xzf "$TMP/dust.tar.gz" -C "$TMP"
        cp "$TMP"/dust-*/dust "$LOCAL_BIN/"
        rm -rf "$TMP"
        success "dust installed"
    fi
else
    success "dust already installed"
fi

success "All essential CLI tools installed"
