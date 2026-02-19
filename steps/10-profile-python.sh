#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "10a — Python Developer Profile Tools"

# ── pyenv ─────────────────────────────────────────────────────────────────────
if [[ -d "$HOME/.pyenv" ]]; then
    success "pyenv already installed"
else
    info "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    success "pyenv installed"
fi

# Ensure pyenv is on PATH for this session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

# Install latest Python 3 via pyenv
if has pyenv; then
    PYTHON_LATEST=$(pyenv install --list 2>/dev/null | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
    if ! pyenv versions | grep -q "$PYTHON_LATEST"; then
        info "Installing Python $PYTHON_LATEST via pyenv..."
        pyenv install "$PYTHON_LATEST"
        pyenv global "$PYTHON_LATEST"
        success "Python $PYTHON_LATEST set as global"
    else
        success "Python $PYTHON_LATEST already installed via pyenv"
    fi
fi

# ── uv (package manager) ──────────────────────────────────────────────────────
if ! has uv; then
    info "Installing uv..."
    curl -fsSL https://astral.sh/uv/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    success "uv installed: $(uv --version 2>/dev/null || echo 'ok')"
else
    success "uv already installed: $(uv --version)"
fi

# ── poetry ────────────────────────────────────────────────────────────────────
if ! has poetry; then
    info "Installing poetry..."
    curl -fsSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
    success "poetry installed"
else
    success "poetry already installed"
fi

# ── pipx (ensure it's functional) ─────────────────────────────────────────────
python3 -m pipx ensurepath 2>/dev/null || true
export PATH="$HOME/.local/bin:$PATH"

# ── Python tools via pipx ─────────────────────────────────────────────────────
PIPX_TOOLS=(ruff mypy ipython cookiecutter)
for tool in "${PIPX_TOOLS[@]}"; do
    if ! has "$tool"; then
        info "  pipx install $tool..."
        pipx install "$tool" 2>/dev/null || pip install --user "$tool" 2>/dev/null || warn "  Could not install $tool"
    else
        info "  $tool already installed"
    fi
done

# ── Jupyter ───────────────────────────────────────────────────────────────────
if ! has jupyter; then
    info "Installing JupyterLab via pipx..."
    pipx install jupyterlab 2>/dev/null || pip install --user jupyterlab 2>/dev/null || warn "JupyterLab install failed"
else
    success "Jupyter already installed"
fi

success "Python profile tools installed"
