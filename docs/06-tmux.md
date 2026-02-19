# Step 06 — Tmux + Oh My Tmux

**Script:** `steps/06-tmux.sh`

Installs Tmux, the Oh My Tmux configuration framework, and the Tmux Plugin Manager (TPM) with a set of essential plugins. Writes a Catppuccin Mocha themed `~/.tmux.conf.local`.

---

## What it does

### 1. Install Tmux

Installed via `apt-get install -y tmux` if not already present.

### 2. Install TPM (Tmux Plugin Manager)

Cloned from `tmux-plugins/tpm` into `~/.tmux/plugins/tpm`. TPM is used to manage all Tmux plugins.

### 3. Install Oh My Tmux

Cloned from `gpakosz/.tmux` into `~/.oh-my-tmux`. The main config file is symlinked:

```
~/.tmux.conf → ~/.oh-my-tmux/.tmux.conf
```

Oh My Tmux provides a sensible base config, a rich status bar, and a well-organized local override system.

### 4. Write `~/.tmux.conf.local`

This is the user customization file that Oh My Tmux merges with its base config.

---

## Configuration details

### Prefix key

Changed from the default `Ctrl+B` to **`Ctrl+Space`** — more ergonomic.

### Mouse

Mouse support is enabled: click to select panes/windows, scroll to scroll pane history.

### Terminal colors

```
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```

Enables full 24-bit true color inside Tmux.

### Pane navigation (no prefix needed)

| Shortcut | Action |
|----------|--------|
| `Alt+←` | Select left pane |
| `Alt+→` | Select right pane |
| `Alt+↑` | Select pane above |
| `Alt+↓` | Select pane below |

### Pane resizing

| Shortcut | Action |
|----------|--------|
| `Alt+Shift+←` | Resize pane left 5 |
| `Alt+Shift+→` | Resize pane right 5 |
| `Alt+Shift+↑` | Resize pane up 5 |
| `Alt+Shift+↓` | Resize pane down 5 |

### Window management

| Binding | Action |
|---------|--------|
| `Prefix + \|` | Split horizontally (keeps current path) |
| `Prefix + -` | Split vertically (keeps current path) |
| `Prefix + c` | New window (keeps current path) |
| `Alt+1` through `Alt+5` | Jump directly to window 1–5 |
| `Prefix + r` | Reload tmux config |

### Plugins

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tmux-sensible` | Sensible defaults for Tmux |
| `tmux-plugins/tmux-resurrect` | Save and restore sessions (`Prefix+Ctrl+S` / `Prefix+Ctrl+R`) |
| `tmux-plugins/tmux-continuum` | Auto-save sessions every 15 minutes; auto-restore on start |
| `tmux-plugins/tmux-yank` | Copy to system clipboard with mouse or `Prefix+y` |

#### Resurrect settings

- Pane contents are captured
- Neovim sessions are restored using the `session` strategy

### Status bar (Catppuccin Mocha theme)

The Oh My Tmux status bar is colored using Catppuccin Mocha palette variables (`tmux_conf_theme_colour_*`):

- **Left:** `#S` — current session name
- **Right:** prefix indicator, pairing/sync indicator, time, date, username

Active window tab: blue background, dark text.

---

## Files written

| File | Content |
|------|---------|
| `~/.tmux.conf` | Symlink to `~/.oh-my-tmux/.tmux.conf` |
| `~/.tmux.conf.local` | Custom overrides with Catppuccin Mocha theme and keybindings |

---

## First run

After setup, open Tmux and install plugins:

```bash
tmux
# Inside tmux:
# Prefix + I   (capital i) — install all plugins
```

---

## Progress key

`06-tmux.sh` is written to `~/.dev-setup.progress` on success.
