# Step 05 — Essential CLI Tools

**Script:** `steps/05-tools.sh`

Installs a curated set of modern CLI utilities that replace or augment standard Unix tools. Each tool is installed only if not already present.

---

## Tools installed

### `eza` — modern `ls`

Installed via the official `deb.gierens.de` apt repository. Provides color output, icons, git status, and tree views.

> Aliased to `ls`, `ll`, `la`, `lt`, `lt3` in `.zshrc`.

### `bat` — modern `cat`

Downloaded from `sharkdp/bat` GitHub releases (static binary). On Ubuntu, `batcat` may already be installed — in that case a symlink `bat → batcat` is created in `~/.local/bin`.

Configured with Catppuccin Mocha theme and used as `MANPAGER`.

> Aliased to `cat` in `.zshrc`.

### `ripgrep` (`rg`) — modern `grep`

Downloaded from `BurntSushi/ripgrep` GitHub releases (musl static binary). Extremely fast recursive search respecting `.gitignore`.

> Aliased to `grep` in `.zshrc`.

### `fd` — modern `find`

Downloaded from `sharkdp/fd` GitHub releases. On Ubuntu, `fdfind` may exist — symlink `fd → fdfind` is created if needed.

> Aliased to `find` in `.zshrc`. Also used as the `fzf` default command.

### `fzf` — fuzzy finder

Cloned from `junegunn/fzf` and installed via its own install script (key bindings + completions enabled for Zsh, not Bash/Fish). Provides:
- `Ctrl+R` — fuzzy history search
- `Ctrl+T` — fuzzy file picker
- `Alt+C` — fuzzy directory jump

Configured with Catppuccin Mocha colors in `.zshrc`.

### `zoxide` — smart `cd`

Installed via the official install script. Learns your most-visited directories and lets you jump with `z <partial-name>`.

Initialized in `.zshrc` with `eval "$(zoxide init zsh)"`.

### `delta` — git diff pager

Downloaded from `dandavison/delta` GitHub releases. Provides syntax-highlighted, side-by-side git diffs.

Configured globally in step 09 (inline in `setup.sh`):

| git config | Value |
|-----------|-------|
| `core.pager` | `delta` |
| `delta.side-by-side` | `true` |
| `delta.line-numbers` | `true` |
| `delta.syntax-theme` | `Catppuccin Mocha` |
| `delta.navigate` | `true` |

### `btop` — resource monitor

Installed via apt (`btop` package). Falls back to downloading the GitHub release binary if the apt version is unavailable.

> Aliased to `top` in `.zshrc`.

### `tldr` — simplified man pages

Prefers `tealdeer` (Rust implementation, single static binary) from `dbrgn/tealdeer` GitHub releases. Falls back to apt or `pipx install tldr`.

### `jq` — JSON processor

Installed via apt if not already present. Essential for scripts and API work.

### `yq` — YAML processor

Downloaded from `mikefarah/yq` GitHub releases (single static binary). Works like `jq` but for YAML, TOML, XML, and CSV.

### `httpie` — HTTP client

Installed via `apt-get install httpie` or `pipx install httpie`. Provides the `http` and `https` commands for readable HTTP requests.

### `duf` — disk usage / free

Downloaded from `muesli/duf` GitHub releases (`.deb` package). Shows disk usage in a beautiful table.

> Aliased to `df` in `.zshrc`.

### `dust` — directory size

Downloaded from `bootandy/dust` GitHub releases (musl static binary). Shows directory sizes like `du` but with a visual tree.

> Aliased to `du` in `.zshrc`.

---

## Install location

Most binaries go to `~/.local/bin/` which is prepended to `$PATH` in `.zshrc`.

---

## Progress key

`05-tools.sh` is written to `~/.dev-setup.progress` on success.
