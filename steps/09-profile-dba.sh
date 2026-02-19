#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "09a — DBA Profile Tools"

# ── pgcli ─────────────────────────────────────────────────────────────────────
if ! has pgcli; then
    info "Installing pgcli..."
    pipx install pgcli
    success "pgcli installed"
else
    success "pgcli already installed"
fi

# ── mycli ─────────────────────────────────────────────────────────────────────
if ! has mycli; then
    info "Installing mycli..."
    pipx install mycli
    success "mycli installed"
else
    success "mycli already installed"
fi

# ── litecli ───────────────────────────────────────────────────────────────────
if ! has litecli; then
    info "Installing litecli..."
    pipx install litecli
    success "litecli installed"
else
    success "litecli already installed"
fi

# ── usql (universal SQL) ──────────────────────────────────────────────────────
if ! has usql; then
    info "Installing usql..."
    USQL_URL=$(github_latest_url "xo/usql" "usql-.*-linux-amd64\.tar\.bz2$")
    if [[ -n "$USQL_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q --show-progress -O "$TMP/usql.tar.bz2" "$USQL_URL"
        tar -xjf "$TMP/usql.tar.bz2" -C "$TMP"
        cp "$TMP/usql" "$HOME/.local/bin/"
        rm -rf "$TMP"
        success "usql installed"
    fi
else
    success "usql already installed"
fi

# ── mongosh ───────────────────────────────────────────────────────────────────
if ! has mongosh; then
    info "Installing mongosh..."
    # MongoDB shell via official .deb
    MONGO_VER="2.3.2"
    MONGOSH_URL="https://downloads.mongodb.com/compass/mongosh-${MONGO_VER}-linux-x64.tgz"
    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/mongosh.tgz" "$MONGOSH_URL" || true
    if [[ -f "$TMP/mongosh.tgz" ]]; then
        tar -xzf "$TMP/mongosh.tgz" -C "$TMP"
        cp "$TMP"/mongosh-*/bin/mongosh "$HOME/.local/bin/"
        cp "$TMP"/mongosh-*/bin/mongocryptd* "$HOME/.local/bin/" 2>/dev/null || true
        rm -rf "$TMP"
        success "mongosh installed"
    else
        warn "Could not download mongosh automatically"
    fi
else
    success "mongosh already installed"
fi

# ── redis-cli ─────────────────────────────────────────────────────────────────
if ! has redis-cli; then
    sudo apt-get install -y redis-tools -qq
fi
success "redis-cli available"

# ── dbeaver-ce (snap) ────────────────────────────────────────────────────────
if ! has dbeaver; then
    info "Installing DBeaver CE via snap..."
    sudo snap install dbeaver-ce 2>/dev/null && success "DBeaver CE installed" \
        || warn "DBeaver CE snap install failed — install manually if needed"
else
    success "DBeaver CE already installed"
fi

# ── pgcli config ──────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config/pgcli"
cat > "$HOME/.config/pgcli/config" << 'EOF'
[main]
# Syntax highlighting style
syntax_style = monokai

# Vi mode for line editing
vi = True

# Always start with autocomplete on
show_bottom_toolbar = True

# Show row count after query
row_limit = 1000

# Multi-line mode (hit Enter twice to execute)
multi_line = True

# Auto-expand output vertically when wider than terminal
expand = auto

# Show timing info
timing = True

# On startup, show connection details
log_file = default
log_level = CRITICAL

# Keystrokes
[alias_dsn]
# Define DSN aliases: alias = postgresql://user:pass@host/db

[named_queries]
# Save named queries here
EOF

success "pgcli config written to ~/.config/pgcli/config"
success "DBA profile tools installed"
