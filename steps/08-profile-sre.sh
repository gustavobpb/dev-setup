#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "08a — SRE/DevOps Profile Tools"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# ── Docker ────────────────────────────────────────────────────────────────────
if ! has docker; then
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    success "Docker installed (re-login required for group membership)"
else
    success "Docker already installed: $(docker --version)"
fi

# ── Docker Compose (v2) ───────────────────────────────────────────────────────
if ! docker compose version &>/dev/null; then
    info "Installing Docker Compose plugin..."
    COMPOSE_URL=$(github_latest_url "docker/compose" "linux-x86_64$")
    [[ -z "$COMPOSE_URL" ]] && COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64"
    sudo mkdir -p /usr/local/lib/docker/cli-plugins
    sudo wget -q --show-progress -O /usr/local/lib/docker/cli-plugins/docker-compose "$COMPOSE_URL"
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    success "Docker Compose installed"
else
    success "Docker Compose already installed"
fi

# ── kubectl ────────────────────────────────────────────────────────────────────
if ! has kubectl; then
    info "Installing kubectl..."
    KUBECTL_VER=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl" -o "$LOCAL_BIN/kubectl"
    chmod +x "$LOCAL_BIN/kubectl"
    success "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    success "kubectl already installed"
fi

# ── kubectx + kubens ──────────────────────────────────────────────────────────
if ! has kubectx; then
    info "Installing kubectx/kubens..."
    KCTX_URL=$(github_latest_url "ahmetb/kubectx" "kubectx_.*_linux_x86_64\.tar\.gz$")
    KNS_URL=$(github_latest_url "ahmetb/kubectx" "kubens_.*_linux_x86_64\.tar\.gz$")
    if [[ -n "$KCTX_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q -O "$TMP/kubectx.tar.gz" "$KCTX_URL"
        wget -q -O "$TMP/kubens.tar.gz" "$KNS_URL"
        tar -xzf "$TMP/kubectx.tar.gz" -C "$TMP"
        tar -xzf "$TMP/kubens.tar.gz" -C "$TMP"
        cp "$TMP/kubectx" "$LOCAL_BIN/"
        cp "$TMP/kubens" "$LOCAL_BIN/"
        rm -rf "$TMP"
        success "kubectx + kubens installed"
    fi
else
    success "kubectx already installed"
fi

# ── helm ──────────────────────────────────────────────────────────────────────
if ! has helm; then
    info "Installing Helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    success "Helm installed: $(helm version --short)"
else
    success "Helm already installed"
fi

# ── k9s ───────────────────────────────────────────────────────────────────────
if ! has k9s; then
    info "Installing k9s..."
    K9S_URL=$(github_latest_url "derailed/k9s" "Linux_amd64\.tar\.gz$")
    if [[ -n "$K9S_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q --show-progress -O "$TMP/k9s.tar.gz" "$K9S_URL"
        tar -xzf "$TMP/k9s.tar.gz" -C "$TMP"
        cp "$TMP/k9s" "$LOCAL_BIN/"
        rm -rf "$TMP"
        success "k9s installed: $(k9s version --short 2>/dev/null | head -1)"
    fi
else
    success "k9s already installed"
fi

# ── stern (multi-pod log tailing) ─────────────────────────────────────────────
if ! has stern; then
    info "Installing stern..."
    STERN_URL=$(github_latest_url "stern/stern" "linux_amd64\.tar\.gz$")
    if [[ -n "$STERN_URL" ]]; then
        TMP=$(mktemp -d)
        wget -q --show-progress -O "$TMP/stern.tar.gz" "$STERN_URL"
        tar -xzf "$TMP/stern.tar.gz" -C "$TMP"
        cp "$TMP/stern" "$LOCAL_BIN/"
        rm -rf "$TMP"
        success "stern installed"
    fi
else
    success "stern already installed"
fi

# ── lazydocker ────────────────────────────────────────────────────────────────
if ! has lazydocker; then
    info "Installing lazydocker..."
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    success "lazydocker installed"
else
    success "lazydocker already installed"
fi

# ── Terraform ─────────────────────────────────────────────────────────────────
if ! has terraform; then
    info "Installing Terraform..."
    wget -qO- https://apt.releases.hashicorp.com/gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y terraform -qq
    success "Terraform installed: $(terraform version | head -1)"
else
    success "Terraform already installed"
fi

# ── Ansible ───────────────────────────────────────────────────────────────────
if ! has ansible; then
    info "Installing Ansible..."
    sudo apt-get install -y ansible -qq 2>/dev/null || \
        pipx install ansible-core
    success "Ansible installed"
else
    success "Ansible already installed"
fi

# ── AWS CLI v2 ────────────────────────────────────────────────────────────────
if ! has aws; then
    info "Installing AWS CLI v2..."
    TMP=$(mktemp -d)
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$TMP/awscliv2.zip"
    unzip -q "$TMP/awscliv2.zip" -d "$TMP"
    sudo "$TMP/aws/install" --update
    rm -rf "$TMP"
    success "AWS CLI installed: $(aws --version)"
else
    success "AWS CLI already installed"
fi

# ── gcloud SDK ────────────────────────────────────────────────────────────────
if ! has gcloud; then
    info "Installing Google Cloud SDK..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
        | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    sudo apt-get update -qq
    sudo apt-get install -y google-cloud-cli -qq
    success "gcloud installed: $(gcloud --version | head -1)"
else
    success "gcloud already installed"
fi

# ── Flux CLI ──────────────────────────────────────────────────────────────────
if ! has flux; then
    info "Installing Flux CLI..."
    curl -fsSL https://fluxcd.io/install.sh | sudo bash
    success "Flux installed: $(flux --version)"
else
    success "Flux already installed"
fi

success "SRE profile tools installed"
