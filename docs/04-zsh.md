# Step 04 — Zsh + Oh My Zsh + Powerlevel10k

**Script:** `steps/04-zsh.sh`

Installs the full Zsh stack: the shell itself, Oh My Zsh framework, Powerlevel10k theme, community plugins, and writes a pre-configured `~/.zshrc` and `~/.p10k.zsh`.

---

## What it does

### 1. Install Zsh

Installs `zsh` via apt if missing, then sets it as the default shell with `usermod -s`. Zsh is added to `/etc/shells` if not already listed (required by `usermod`).

> The shell change takes effect on next login (or `exec zsh`).

### 2. Install Oh My Zsh

Cloned from the official installer with `RUNZSH=no CHSH=no KEEP_ZSHRC=yes` to avoid overwriting the existing shell and `.zshrc` during install. Installed at `~/.oh-my-zsh`.

### 3. Install Powerlevel10k

Cloned into `~/.oh-my-zsh/custom/themes/powerlevel10k`.

### 4. Install Zsh plugins

| Plugin | Source | Purpose |
|--------|--------|---------|
| `zsh-autosuggestions` | `zsh-users/zsh-autosuggestions` | Fish-like command suggestions |
| `zsh-syntax-highlighting` | `zsh-users/zsh-syntax-highlighting` | Live syntax coloring |
| `zsh-completions` | `zsh-users/zsh-completions` | Extra completion definitions |
| `autojump` | apt (step 01) | Jump to frecent dirs with `j` |
| `fzf` | oh-my-zsh built-in | Ctrl+R history, Ctrl+T file search |
| `colored-man-pages` | oh-my-zsh built-in | Colorized man pages |
| `copypath` / `copyfile` | oh-my-zsh built-in | Copy path/file content to clipboard |
| `history-substring-search` | oh-my-zsh built-in | Up arrow searches history |
| `aliases` / `sudo` | oh-my-zsh built-in | Alias lister, Esc+Esc sudo prefix |
| `git` | oh-my-zsh built-in | Git aliases and prompt info |

### 5. Write `~/.p10k.zsh`

Written only if it does not already exist. Configures Powerlevel10k with a **lean style** and **Catppuccin Mocha** color palette.

**Left prompt segments:** `os_icon` → `dir` → `vcs` → `newline` → `prompt_char`

**Right prompt segments:** `status` → `command_execution_time` → `virtualenv` → `pyenv` → `node_version` → `go_version` → `rust_version` → `kubecontext` → `terraform` → `aws` → `background_jobs` → `time`

Context-sensitive segments only show when relevant commands are running:
- `kubecontext` — visible when running `kubectl`, `helm`, `k9s`, `flux`, etc.
- `terraform` — visible when running `terraform`, `terragrunt`, `packer`
- `aws` — visible when running `aws`, `awless`, `cdk`
- `node_version`, `go_version`, `rust_version` — only in project directories

### 6. Write `~/.zshrc`

Written only if `DEV_PROFILE` marker is not already in the file (preserves manual customizations).

Key sections configured:

| Section | Details |
|---------|---------|
| Welcome message | Hostname, date, active profile shown on shell start |
| P10k instant prompt | Enabled for fast shell startup |
| PATH | `~/.local/bin`, `~/bin`, `~/scripts` prepended |
| History | 50,000 lines, deduped, shared across sessions |
| fzf | Catppuccin Mocha colors; `fd` as default command |
| zoxide | Initialized as smart `cd` replacement |
| bat | `BAT_THEME=Catppuccin Mocha`; used as `MANPAGER` |
| delta | Set as `GIT_PAGER` |
| Editor | `EDITOR=nvim`, `VISUAL=nvim` |
| Aliases | Modern tool replacements (see below) |
| Functions | `mkcd`, `fif`, `fcd`, `fo`, `gfb`, `fkill`, `extract` |
| Profile selector | `switch-profile` / `sp` function using fzf |

#### Shell aliases

| Alias | Expands to |
|-------|-----------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -la --icons --git --group-directories-first` |
| `la` | `eza -a --icons` |
| `lt` / `lt3` | `eza --tree --icons --level=2/3` |
| `cat` | `bat` |
| `grep` | `rg` |
| `find` | `fd` |
| `top` | `btop` |
| `df` | `duf` |
| `du` | `dust` |
| `vim` / `vi` / `v` | `nvim` |
| `gs` | `git status` |
| `gl` | `git log --oneline --graph --decorate --all` |
| `sp` | `switch-profile` |

#### Shell functions

| Function | Description |
|----------|------------|
| `mkcd <dir>` | `mkdir -p` then `cd` into new directory |
| `fif <pattern>` | Find files containing pattern, preview with bat |
| `fcd` | Fuzzy-select a directory and `cd` into it |
| `fo` | Fuzzy-select a file and open in `$EDITOR` |
| `gfb` | Fuzzy-select and checkout a git branch |
| `fkill` | Fuzzy-select and kill a process |
| `extract <file>` | Auto-detect archive type and extract it |

---

## Files written

| File | Content |
|------|---------|
| `~/.zshrc` | Full Zsh configuration |
| `~/.p10k.zsh` | Powerlevel10k prompt configuration |

---

## Progress key

`04-zsh.sh` is written to `~/.dev-setup.progress` on success.
