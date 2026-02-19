# Step 03 — Ghostty Terminal

**Script:** `steps/03-ghostty.sh`

Installs the **Ghostty** terminal emulator and writes a Catppuccin Mocha themed configuration, then sets Ghostty as the system default terminal.

---

## What it does

### 1. Install Ghostty (three strategies, in order)

1. **snap** — `sudo snap install ghostty --classic` (fastest if snap is available)
2. **GitHub release `.deb`** — downloads the latest `.deb` from `ghostty-org/ghostty` releases
3. **AppImage** — downloads the `.AppImage` to `~/.local/bin/ghostty` as a last resort

If all three fail, the script warns and continues (non-fatal).

### 2. Write Ghostty config

Creates `~/.config/ghostty/config` with:

| Setting | Value |
|---------|-------|
| Theme | `catppuccin-mocha` |
| Font | JetBrains Mono Nerd Font, size 13 |
| Font features | `calt`, `liga`, `ss01`, `ss02`, `ss19`, `ss20` (ligatures) |
| Background opacity | 0.95 |
| Window padding | 8px x/y |
| Cursor | Block, blinking |
| Scrollback | 10,000 lines |
| Shell integration | zsh |

#### Keybindings configured

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close surface |
| `Ctrl+Shift+N` | New window |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Shift+C` | Copy to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+=` | Increase font size |
| `Ctrl+-` | Decrease font size |
| `Ctrl+0` | Reset font size |

### 3. Write Catppuccin Mocha theme file

Creates `~/.config/ghostty/themes/catppuccin-mocha` with the full 16-color Catppuccin Mocha palette. This is needed when Ghostty is installed via snap (which does not bundle themes).

### 4. Set Ghostty as default terminal

- Registers with `update-alternatives` as `x-terminal-emulator` (used by file managers and most apps).
- Sets GNOME default terminal via `gsettings` (right-click desktop, keyboard shortcut `Ctrl+Alt+T`).

---

## Files written

| File | Content |
|------|---------|
| `~/.config/ghostty/config` | Main Ghostty configuration |
| `~/.config/ghostty/themes/catppuccin-mocha` | Catppuccin Mocha color palette |

---

## Progress key

`03-ghostty.sh` is written to `~/.dev-setup.progress` on success.
