#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "06 — Tmux + Oh My Tmux"

# ── Install tmux ───────────────────────────────────────────────────────────────
if ! has tmux; then
    info "Installing tmux..."
    sudo apt-get install -y tmux -qq
    success "tmux installed: $(tmux -V)"
else
    success "tmux already installed: $(tmux -V)"
fi

# ── Install TPM (Tmux Plugin Manager) ─────────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    success "TPM already installed"
else
    info "Installing TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM installed"
fi

# ── Oh My Tmux ────────────────────────────────────────────────────────────────
OH_MY_TMUX_DIR="$HOME/.oh-my-tmux"
if [[ -d "$OH_MY_TMUX_DIR" ]]; then
    info "Oh My Tmux already installed, pulling updates..."
    git -C "$OH_MY_TMUX_DIR" pull --quiet
else
    info "Installing Oh My Tmux..."
    git clone --depth=1 https://github.com/gpakosz/.tmux.git "$OH_MY_TMUX_DIR"
fi
ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
success "Oh My Tmux linked at ~/.tmux.conf"

# ── Write ~/.tmux.conf.local ───────────────────────────────────────────────────
cat > "$HOME/.tmux.conf.local" << 'TMUXLOCAL'
# ─────────────────────────────────────────────────────────────
#  ~/.tmux.conf.local — Catppuccin Mocha customizations
# ─────────────────────────────────────────────────────────────

# Prefix: Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Mouse support
set -g mouse on

# Terminal colors
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Pane navigation with Alt+Arrow (no prefix needed)
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# Pane resizing with Alt+Shift+Arrow
bind -n M-S-Left  resize-pane -L 5
bind -n M-S-Right resize-pane -R 5
bind -n M-S-Up    resize-pane -U 5
bind -n M-S-Down  resize-pane -D 5

# Split panes with more intuitive keys
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Fast window switching
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5

# Reload config
bind r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"

# ── Catppuccin Mocha colors ────────────────────────────────────────────────────
# Palette
CAT_BASE="#1e1e2e"
CAT_MANTLE="#181825"
CAT_SURFACE0="#313244"
CAT_SURFACE1="#45475a"
CAT_TEXT="#cdd6f4"
CAT_SUBTEXT="#a6adc8"
CAT_BLUE="#89b4fa"
CAT_LAVENDER="#b4befe"
CAT_MAUVE="#cba6f7"
CAT_GREEN="#a6e3a1"
CAT_YELLOW="#f9e2af"
CAT_RED="#f38ba8"
CAT_PINK="#f5c2e7"
CAT_TEAL="#94e2d5"
CAT_PEACH="#fab387"

# ── Status bar ────────────────────────────────────────────────────────────────
tmux_conf_theme_colour_1="#1e1e2e"    # dark background
tmux_conf_theme_colour_2="#313244"    # surface0
tmux_conf_theme_colour_3="#45475a"    # surface1
tmux_conf_theme_colour_4="#89b4fa"    # blue
tmux_conf_theme_colour_5="#f9e2af"    # yellow
tmux_conf_theme_colour_6="#1e1e2e"    # dark (text on status)
tmux_conf_theme_colour_7="#cdd6f4"    # text
tmux_conf_theme_colour_8="#1e1e2e"
tmux_conf_theme_colour_9="#f9e2af"    # yellow (time)
tmux_conf_theme_colour_10="#cba6f7"   # mauve
tmux_conf_theme_colour_11="#a6e3a1"   # green
tmux_conf_theme_colour_12="#cdd6f4"
tmux_conf_theme_colour_13="#cdd6f4"
tmux_conf_theme_colour_14="#1e1e2e"
tmux_conf_theme_colour_15="#1e1e2e"
tmux_conf_theme_colour_16="#f38ba8"   # red
tmux_conf_theme_colour_17="#cdd6f4"

tmux_conf_theme_window_status_current_fg="#1e1e2e"
tmux_conf_theme_window_status_current_bg="#89b4fa"

# Status left/right
tmux_conf_theme_status_left=" #S "
tmux_conf_theme_status_right=" #{prefix}#{pairing}#{synchronized} %R | %d %b | #{username}#{root} "

# Status position
tmux_conf_theme_status_position=bottom

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Resurrect config
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# Continuum: auto-save every 15 min, auto-restore on start
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Initialize TPM (keep this line at the very bottom)
run '~/.tmux/plugins/tpm/tpm'
TMUXLOCAL

success "~/.tmux.conf.local written"

# Install TPM plugins
info "Installing tmux plugins via TPM..."
"$TPM_DIR/bin/install_plugins" 2>/dev/null || true
success "Tmux plugins installed"
