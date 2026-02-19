# Dev Terminal Setup — Ubuntu 24.04

A fully automated, opinionated terminal environment setup for Ubuntu 24.04. Installs and configures a modern, beautiful, and productive developer shell with Ghostty, Zsh, Neovim, Tmux, and a curated set of CLI tools — all themed with **Catppuccin Mocha**.

## Quick Start

```bash
git clone git@github.com:gustavoclickbus/dev-setup.git ~/dev-setup
bash ~/dev-setup/setup.sh
```

## Usage

```
bash setup.sh [OPTIONS]

Options:
  --profiles sre,dba,python,frontend,backend   Install specific role profiles
  --all-profiles                               Install all profile tools
  --skip-neovim                                Skip Neovim/LazyVim installation
  --reset                                      Clear progress and start fresh
  --help, -h                                   Show help

Examples:
  bash setup.sh                                # Interactive — prompts for profiles
  bash setup.sh --profiles python,frontend
  bash setup.sh --all-profiles
  bash setup.sh --skip-neovim --profiles sre
```

> The script is **idempotent**: completed steps are recorded in `~/.dev-setup.progress` and skipped on re-runs. Use `--reset` to start fresh.

---

## What Gets Installed

### Base (always installed)

| Phase | Script | What it does |
|-------|--------|--------------|
| 1 | `steps/01-system.sh` | System packages, build tools, zsh, jq, btop, tmux, redis-tools |
| 2 | `steps/02-fonts.sh` | JetBrains Mono Nerd Font |
| 3 | `steps/03-ghostty.sh` | Ghostty terminal + Catppuccin Mocha config |
| 4 | `steps/04-zsh.sh` | Zsh, Oh My Zsh, Powerlevel10k, plugins, `.zshrc` |
| 5 | `steps/05-tools.sh` | eza, bat, ripgrep, fd, fzf, zoxide, delta, btop, tldr, jq, yq, httpie, duf, dust |
| 6 | `steps/06-tmux.sh` | Tmux, Oh My Tmux, TPM, tmux-resurrect, tmux-continuum |
| 7 | `steps/07-neovim.sh` | Neovim (stable) + LazyVim + LSP/formatter config via Mason |
| — | (inline) | Git configured with delta (side-by-side diffs, Catppuccin theme) |
| — | (inline) | bat configured with Catppuccin Mocha theme |

### Role Profiles (optional)

| Flag | Script | What it installs |
|------|--------|------------------|
| `sre` | `steps/08-profile-sre.sh` | Docker, kubectl, helm, k9s, kubectx/kubens, stern, lazydocker, Terraform, Ansible, AWS CLI, gcloud, Flux |
| `dba` | `steps/09-profile-dba.sh` | pgcli, mycli, litecli, usql, mongosh, redis-cli, DBeaver CE |
| `python` | `steps/10-profile-python.sh` | pyenv, latest Python 3, uv, poetry, ruff, mypy, ipython, JupyterLab |
| `frontend` | `steps/11-profile-frontend.sh` | nvm, Node.js LTS, pnpm, bun, vercel CLI, netlify CLI |
| `backend` | `steps/12-profile-backend.sh` | asdf, Go, Rust, Java 21 (Temurin), Maven, Gradle, grpcurl, websocat, k6, wrk |

---

## Project Structure

```
dev-setup/
├── setup.sh              # Main entry point
├── lib/
│   ├── colors.sh         # Color variables and logging functions
│   └── helpers.sh        # Shared utility functions
├── steps/
│   ├── 01-system.sh      # System packages
│   ├── 02-fonts.sh       # Nerd Fonts
│   ├── 03-ghostty.sh     # Ghostty terminal
│   ├── 04-zsh.sh         # Zsh stack
│   ├── 05-tools.sh       # CLI tools
│   ├── 06-tmux.sh        # Tmux
│   ├── 07-neovim.sh      # Neovim + LazyVim
│   ├── 08-profile-sre.sh # SRE/DevOps tools
│   ├── 09-profile-dba.sh # DBA tools
│   ├── 10-profile-python.sh # Python tools
│   ├── 11-profile-frontend.sh # Frontend tools
│   └── 12-profile-backend.sh  # Backend tools
└── docs/
    ├── 01-system.md
    ├── 02-fonts.md
    ├── 03-ghostty.md
    ├── 04-zsh.md
    ├── 05-tools.md
    ├── 06-tmux.md
    ├── 07-neovim.md
    ├── 08-profile-sre.md
    ├── 09-profile-dba.md
    ├── 10-profile-python.md
    ├── 11-profile-frontend.md
    ├── 12-profile-backend.md
    └── lib.md
```

---

## After Installation

```bash
exec zsh                    # Load the new shell
switch-profile              # Or alias: sp — fuzzy-pick a dev profile
tmux                        # Start tmux, then prefix+I to install plugins
ghostty                     # Start the new terminal
nvim                        # LazyVim auto-installs plugins on first run
p10k configure              # Optional: re-run Powerlevel10k wizard
```

### Key config files

| File | Purpose |
|------|---------|
| `~/.zshrc` | Main Zsh config, aliases, functions, profile loader |
| `~/.p10k.zsh` | Powerlevel10k prompt config |
| `~/.config/ghostty/config` | Ghostty terminal settings |
| `~/.tmux.conf.local` | Tmux customizations (Catppuccin Mocha) |
| `~/.config/nvim/` | Neovim / LazyVim config |
| `~/.zsh/profiles/*.zsh` | Per-role Zsh profile files |

### Shell aliases (highlights)

| Alias | Command |
|-------|---------|
| `ll` | `eza -la --icons --git` |
| `cat` | `bat` |
| `grep` | `rg` |
| `find` | `fd` |
| `top` | `btop` |
| `df` | `duf` |
| `du` | `dust` |
| `vim` / `vi` / `v` | `nvim` |
| `gs`, `ga`, `gc`, `gp` | git shortcuts |
| `sp` | `switch-profile` |
| `z <dir>` | smart `cd` via zoxide |

---

## Requirements

- Ubuntu 24.04 (x86_64)
- `sudo` access
- Internet connection

## Documentation

See the [`docs/`](docs/) folder for detailed per-script documentation.
