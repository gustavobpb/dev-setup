# Step 07 — Neovim + LazyVim

**Script:** `steps/07-neovim.sh`

Installs the latest stable **Neovim** release and bootstraps a **LazyVim** configuration with a pre-configured set of LSP servers, formatters, and linters via Mason.

Skip this step with `--skip-neovim` if you prefer a different editor.

---

## What it does

### 1. Install Neovim (latest stable)

Downloads the official `nvim-linux-x86_64.tar.gz` from `neovim/neovim` GitHub releases (falls back to a pinned stable URL). Extracts directly into `~/.local/` (binaries end up in `~/.local/bin/nvim`).

### 2. Bootstrap LazyVim

Clones the [LazyVim starter](https://github.com/LazyVim/starter) into `~/.config/nvim`. If a config already exists, it is backed up to `~/.config/nvim.bak.<timestamp>`.

LazyVim auto-installs all plugins on the first `nvim` launch.

### 3. Write Mason LSP config

Creates `~/.config/nvim/lua/plugins/mason-lsp.lua` which tells Mason to automatically install the following tools:

#### LSP Servers

| Server | Language |
|--------|---------|
| `pyright` | Python |
| `typescript-language-server` | TypeScript / JavaScript |
| `gopls` | Go |
| `rust-analyzer` | Rust |
| `lua-language-server` | Lua |
| `bash-language-server` | Bash/Shell |
| `sqls` | SQL |
| `yaml-language-server` | YAML |
| `json-lsp` | JSON |
| `terraform-ls` | Terraform |

#### Formatters

| Tool | Language |
|------|---------|
| `black` | Python |
| `prettier` | JS/TS/CSS/HTML/JSON/YAML |
| `stylua` | Lua |
| `shfmt` | Shell |
| `gofumpt` | Go |

#### Linters

| Tool | Language |
|------|---------|
| `ruff` | Python |
| `eslint_d` | JavaScript / TypeScript |
| `shellcheck` | Shell scripts |
| `tflint` | Terraform |

---

## Files written

| File | Content |
|------|---------|
| `~/.local/bin/nvim` | Neovim binary |
| `~/.config/nvim/` | LazyVim starter config |
| `~/.config/nvim/lua/plugins/mason-lsp.lua` | Mason LSP/formatter/linter config |

---

## First run

```bash
nvim
```

LazyVim will automatically install all plugins via `lazy.nvim`, then Mason will install LSP servers and formatters in the background. This may take a few minutes on first launch.

---

## Progress key

`07-neovim.sh` is written to `~/.dev-setup.progress` on success.
