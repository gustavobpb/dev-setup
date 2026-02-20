#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "03 — Ghostty terminal"

install_ghostty() {
    # Try snap first
    if has snap; then
        info "  Trying snap install..."
        if sudo snap install ghostty --classic 2>/dev/null; then
            success "  Ghostty installed via snap"
            return 0
        fi
    fi

    # Try official .deb from GitHub releases
    info "  Trying GitHub release .deb..."
    DEB_URL=$(github_latest_url "ghostty-org/ghostty" "linux.*amd64.*\.deb|amd64.*linux.*\.deb|ghostty.*amd64\.deb")
    if [[ -n "$DEB_URL" ]]; then
        TMP_DEB=$(mktemp /tmp/ghostty.XXXXXX.deb)
        wget -q --show-progress -O "$TMP_DEB" "$DEB_URL"
        sudo dpkg -i "$TMP_DEB" && rm -f "$TMP_DEB"
        sudo apt-get install -f -y -qq
        success "  Ghostty installed via .deb"
        return 0
    fi

    # Try AppImage
    info "  Trying AppImage..."
    APPIMAGE_URL=$(github_latest_url "ghostty-org/ghostty" "\.AppImage$")
    if [[ -n "$APPIMAGE_URL" ]]; then
        mkdir -p "$HOME/.local/bin"
        wget -q --show-progress -O "$HOME/.local/bin/ghostty" "$APPIMAGE_URL"
        chmod +x "$HOME/.local/bin/ghostty"
        success "  Ghostty installed as AppImage at ~/.local/bin/ghostty"
        return 0
    fi

    warn "  Could not install Ghostty automatically."
    warn "  Visit https://ghostty.org/download for manual install."
    return 1
}

if has ghostty; then
    success "Ghostty already installed: $(ghostty --version 2>/dev/null || echo 'ok')"
else
    install_ghostty || true
fi

# Write Ghostty config
step "03 — Ghostty config"
mkdir -p "$HOME/.config/ghostty"
cat > "$HOME/.config/ghostty/config" << 'EOF'
# Ghostty Configuration — Catppuccin Mocha

theme = catppuccin-mocha

font-family = JetBrainsMono Nerd Font
font-size = 13
font-feature = calt   # ligatures
font-feature = liga
font-feature = ss01
font-feature = ss02
font-feature = ss19
font-feature = ss20

background-opacity = 0.95
window-padding-x = 8
window-padding-y = 8

cursor-style = block
cursor-style-blink = true

scrollback-limit = 10000
mouse-hide-while-typing = true

# Shell integration
shell-integration = zsh

# Keybindings
keybind = ctrl+shift+t=new_tab
keybind = ctrl+shift+w=close_surface
keybind = ctrl+shift+n=new_window
keybind = ctrl+tab=next_tab
keybind = ctrl+shift+tab=previous_tab
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = ctrl+equal=increase_font_size:1
keybind = ctrl+minus=decrease_font_size:1
keybind = ctrl+zero=reset_font_size
EOF

# Write Catppuccin Mocha theme (not bundled in snap install)
mkdir -p "$HOME/.config/ghostty/themes"
cat > "$HOME/.config/ghostty/themes/catppuccin-mocha" << 'EOF'
palette = 0=#45475a
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#bac2de
palette = 8=#585b70
palette = 9=#f38ba8
palette = 10=#a6e3a1
palette = 11=#f9e2af
palette = 12=#89b4fa
palette = 13=#f5c2e7
palette = 14=#94e2d5
palette = 15=#a6adc8
background = 1e1e2e
foreground = cdd6f4
cursor-color = f5e0dc
selection-background = 313244
selection-foreground = cdd6f4
EOF

success "Ghostty config written to ~/.config/ghostty/config"

# Set Ghostty as default terminal
if has ghostty; then
    GHOSTTY_BIN=$(which ghostty)
    GHOSTTY_WRAPPER="$HOME/.local/bin/ghostty-launch"

    # Create a wrapper that forces NVIDIA OpenGL.
    # Without this, GTK4/EGL defaults to Mesa/ZINK which fails on NVIDIA GPUs
    # (libEGL warning: egl: failed to create dri2 screen), preventing any window
    # from rendering. The wrapper sets the GLVND vendor selection env vars.
    mkdir -p "$HOME/.local/bin"
    cat > "$GHOSTTY_WRAPPER" << 'WRAPEOF'
#!/usr/bin/env bash
# Force NVIDIA OpenGL instead of Mesa/ZINK
if lsmod 2>/dev/null | grep -q "^nvidia"; then
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json
fi
exec /snap/bin/ghostty "$@"
WRAPEOF
    chmod +x "$GHOSTTY_WRAPPER"
    success "Ghostty NVIDIA wrapper created at $GHOSTTY_WRAPPER"

    # Register with update-alternatives (used by most apps and file managers)
    if command -v update-alternatives &>/dev/null; then
        sudo update-alternatives --install \
            /usr/bin/x-terminal-emulator x-terminal-emulator "$GHOSTTY_WRAPPER" 50 2>/dev/null || true
        sudo update-alternatives --set x-terminal-emulator "$GHOSTTY_WRAPPER" 2>/dev/null || true
        success "Ghostty set as x-terminal-emulator default"
    fi

    # Set as GNOME default terminal
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec "$GHOSTTY_WRAPPER" 2>/dev/null || true
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg '' 2>/dev/null || true
        success "Ghostty set as GNOME default terminal"
    fi

    # Fix broken snap desktop entry — the snap's Exec points to an internal build path
    # that doesn't exist on the host. Use the NVIDIA wrapper instead.
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/com.mitchellh.ghostty.desktop" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Name=Ghostty
Type=Application
Comment=A terminal emulator
TryExec=${GHOSTTY_WRAPPER}
Exec=${GHOSTTY_WRAPPER} --gtk-single-instance=true
Icon=com.mitchellh.ghostty
Categories=System;TerminalEmulator;
Keywords=terminal;tty;pty;
StartupNotify=true
StartupWMClass=com.mitchellh.ghostty
Terminal=false
Actions=new-window;
X-GNOME-UsesNotifications=true
X-TerminalArgExec=-e
X-TerminalArgTitle=--title=
X-TerminalArgAppId=--class=
X-TerminalArgDir=--working-directory=
X-TerminalArgHold=--wait-after-command
DBusActivatable=false

[Desktop Action new-window]
Name=New Window
Exec=${GHOSTTY_WRAPPER} --gtk-single-instance=true
DESKTOPEOF
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    success "Ghostty desktop entry fixed"

    # Set Ctrl+Alt+T as a custom keybinding to the NVIDIA wrapper.
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys terminal [] 2>/dev/null || true
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
            "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']" 2>/dev/null || true
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
            name 'Ghostty Terminal' 2>/dev/null || true
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
            command "$GHOSTTY_WRAPPER" 2>/dev/null || true
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
            binding '<Primary><Alt>t' 2>/dev/null || true
        success "Ctrl+Alt+T → Ghostty keybinding configured"
    fi
fi
