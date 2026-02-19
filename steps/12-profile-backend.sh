#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "12a — Backend Developer Profile Tools"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# ── asdf ──────────────────────────────────────────────────────────────────────
ASDF_DIR="$HOME/.asdf"
if is_step_done "12/asdf"; then
    success "asdf already done"
elif [[ -d "$ASDF_DIR" ]]; then
    success "asdf already installed"
    step_done "12/asdf"
else
    info "Installing asdf..."
    git clone --depth=1 https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.14.1
    step_done "12/asdf"
    success "asdf installed"
fi
# shellcheck source=/dev/null
[[ -f "$ASDF_DIR/asdf.sh" ]] && source "$ASDF_DIR/asdf.sh"

# ── Go (via asdf) ─────────────────────────────────────────────────────────────
if is_step_done "12/go"; then
    success "Go already done"
elif has go; then
    success "Go already installed: $(go version)"
    step_done "12/go"
elif has asdf; then
    info "Installing Go via asdf..."
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git 2>/dev/null || true
    GO_LATEST=$(asdf list all golang 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 || true)
    asdf install golang "${GO_LATEST:-1.23.4}"
    asdf global golang "${GO_LATEST:-1.23.4}"
    step_done "12/go"
    success "Go installed: $(go version)"
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
if is_step_done "12/rust"; then
    success "Rust already done"
    source "$HOME/.cargo/env" 2>/dev/null || true
elif has rustup; then
    success "Rust already installed: $(rustc --version)"
    source "$HOME/.cargo/env" 2>/dev/null || true
    step_done "12/rust"
else
    info "Installing Rust via rustup..."
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    step_done "12/rust"
    success "Rust installed: $(rustc --version)"
fi

# ── Java LTS (via asdf) ───────────────────────────────────────────────────────
if is_step_done "12/java"; then
    success "Java already done"
elif has java; then
    success "Java already installed: $(java --version | head -1)"
    step_done "12/java"
elif has asdf; then
    info "Installing Java LTS (Temurin) via asdf..."
    asdf plugin add java https://github.com/halcyon/asdf-java.git 2>/dev/null || true
    JAVA_LATEST=$(asdf list all java 2>/dev/null | grep "temurin-21" | tail -1 | tr -d ' ' || true)
    asdf install java "${JAVA_LATEST:-temurin-21.0.5+11}"
    asdf global java "${JAVA_LATEST:-temurin-21.0.5+11}"
    step_done "12/java"
    success "Java installed: $(java --version | head -1)"
fi

# ── Maven + Gradle ────────────────────────────────────────────────────────────
if is_step_done "12/maven"; then
    success "Maven already done"
elif has mvn; then
    success "Maven already installed"
    step_done "12/maven"
else
    info "Installing Maven..."
    sudo apt-get install -y maven -qq
    step_done "12/maven"
    success "Maven installed: $(mvn --version | head -1)"
fi

if is_step_done "12/gradle"; then
    success "Gradle already done"
elif has gradle; then
    success "Gradle already installed"
    step_done "12/gradle"
else
    info "Installing Gradle..."
    sudo apt-get install -y gradle -qq 2>/dev/null || {
        if has asdf; then
            asdf plugin add gradle 2>/dev/null || true
            GRADLE_LATEST=$(asdf list all gradle 2>/dev/null | grep -E '^[0-9]+\.[0-9]+' | tail -1 | tr -d ' ' || true)
            asdf install gradle "${GRADLE_LATEST:-8.11.1}"
            asdf global gradle "${GRADLE_LATEST:-8.11.1}"
        fi
    }
    step_done "12/gradle"
    success "Gradle installed"
fi

# ── grpcurl ───────────────────────────────────────────────────────────────────
if is_step_done "12/grpcurl"; then
    success "grpcurl already done"
elif has grpcurl; then
    success "grpcurl already installed"
    step_done "12/grpcurl"
else
    info "Installing grpcurl..."
    GRPCURL_URL=$(github_latest_url "fullstorydev/grpcurl" "linux_amd64\.tar\.gz$")
    if [[ -n "$GRPCURL_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q --show-progress -O "$TMP/grpcurl.tar.gz" "$GRPCURL_URL"
        tar -xzf "$TMP/grpcurl.tar.gz" -C "$TMP"
        cp "$TMP/grpcurl" "$LOCAL_BIN/"
        rm -rf "$TMP"
        step_done "12/grpcurl"
        success "grpcurl installed"
    fi
fi

# ── websocat ──────────────────────────────────────────────────────────────────
if is_step_done "12/websocat"; then
    success "websocat already done"
elif has websocat; then
    success "websocat already installed"
    step_done "12/websocat"
else
    info "Installing websocat..."
    WEBSOCAT_URL=$(github_latest_url "vi/websocat" "websocat\.x86_64-unknown-linux-musl$")
    if [[ -n "$WEBSOCAT_URL" ]]; then
        wget -q --show-progress -O "$LOCAL_BIN/websocat" "$WEBSOCAT_URL"
        chmod +x "$LOCAL_BIN/websocat"
        step_done "12/websocat"
        success "websocat installed"
    fi
fi

# ── k6 (load testing) ─────────────────────────────────────────────────────────
if is_step_done "12/k6"; then
    success "k6 already done"
elif has k6; then
    success "k6 already installed"
    step_done "12/k6"
else
    info "Installing k6..."
    # Clean up any broken previous attempt
    sudo rm -f /usr/share/keyrings/k6-archive-keyring.gpg /etc/apt/sources.list.d/k6.list
    K6_VER=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        https://github.com/grafana/k6/releases/latest 2>/dev/null \
        | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
    [[ -z "$K6_VER" ]] && K6_VER="v0.55.0"
    TMP_DEB=$(mktemp /tmp/k6.XXXXXX.deb)
    wget -q --show-progress -O "$TMP_DEB" \
        "https://github.com/grafana/k6/releases/download/${K6_VER}/k6-${K6_VER}-linux-amd64.deb"
    sudo apt install -y -qq "$TMP_DEB"
    rm -f "$TMP_DEB"
    step_done "12/k6"
    success "k6 installed: $(k6 version 2>/dev/null | head -1)"
fi

# ── wrk (HTTP benchmarking) ───────────────────────────────────────────────────
if is_step_done "12/wrk"; then
    success "wrk already done"
elif has wrk; then
    success "wrk already installed"
    step_done "12/wrk"
else
    info "Installing wrk..."
    sudo apt-get install -y wrk -qq 2>/dev/null || {
        # Build from source if not in apt
        TMP=$(mktemp -d)
        git clone --depth=1 https://github.com/wg/wrk "$TMP/wrk"
        make -C "$TMP/wrk" -j"$(nproc)"
        cp "$TMP/wrk/wrk" "$LOCAL_BIN/"
        rm -rf "$TMP"
    }
    step_done "12/wrk"
    success "wrk installed"
fi

success "Backend profile tools installed"
