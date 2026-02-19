#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "07 — Neovim + LazyVim"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# ── Install latest stable Neovim ───────────────────────────────────────────────
install_neovim() {
    info "Downloading latest stable Neovim..."
    NVIM_URL=$(github_latest_url "neovim/neovim" "nvim-linux-x86_64\.tar\.gz$")
    [[ -z "$NVIM_URL" ]] && NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"

    TMP=$(mktemp -d)
    wget -q --show-progress -O "$TMP/nvim.tar.gz" "$NVIM_URL"
    tar -xzf "$TMP/nvim.tar.gz" -C "$HOME/.local" --strip-components=1
    rm -rf "$TMP"
    success "Neovim installed: $(nvim --version | head -1)"
}

if has nvim; then
    NVIM_VER=$(nvim --version | head -1)
    success "Neovim already installed: $NVIM_VER"
else
    install_neovim
fi

# ── LazyVim ───────────────────────────────────────────────────────────────────
NVIM_CONFIG="$HOME/.config/nvim"
if [[ -d "$NVIM_CONFIG/.git" ]]; then
    success "LazyVim already configured at $NVIM_CONFIG"
else
    if [[ -d "$NVIM_CONFIG" ]]; then
        info "Backing up existing nvim config..."
        mv "$NVIM_CONFIG" "${NVIM_CONFIG}.bak.$(date +%s)"
    fi
    info "Cloning LazyVim starter..."
    git clone --depth=1 https://github.com/LazyVim/starter "$NVIM_CONFIG"
    rm -rf "$NVIM_CONFIG/.git"
    success "LazyVim starter installed at $NVIM_CONFIG"
fi

# ── LazyVim LSP configuration ─────────────────────────────────────────────────
# Write a Mason ensure_installed config for the requested LSPs
mkdir -p "$NVIM_CONFIG/lua/plugins"
cat > "$NVIM_CONFIG/lua/plugins/mason-lsp.lua" << 'LUA'
-- Mason LSP auto-install configuration
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "pyright",            -- Python
        "typescript-language-server", -- TypeScript/JS
        "gopls",              -- Go
        "rust-analyzer",      -- Rust
        "lua-language-server",-- Lua
        "bash-language-server",-- Bash
        "sqls",               -- SQL
        "yaml-language-server",-- YAML
        "json-lsp",           -- JSON
        "terraform-ls",       -- Terraform
        -- Formatters
        "black",              -- Python formatter
        "prettier",           -- JS/TS/CSS/HTML formatter
        "stylua",             -- Lua formatter
        "shfmt",              -- Shell formatter
        "gofumpt",            -- Go formatter
        -- Linters
        "ruff",               -- Python linter
        "eslint_d",           -- JS/TS linter
        "shellcheck",         -- Shell linter
        "tflint",             -- Terraform linter
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        tsserver = {},
        gopls = {},
        rust_analyzer = {},
        lua_ls = {},
        bashls = {},
        sqls = {},
        yamlls = {},
        jsonls = {},
        terraformls = {},
      },
    },
  },
}
LUA

success "LSP/Mason config written to $NVIM_CONFIG/lua/plugins/mason-lsp.lua"
info "Run 'nvim' after setup to complete LazyVim plugin installation (auto-runs on first start)"
