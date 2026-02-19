#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"

step "04 — Zsh + Oh My Zsh + Powerlevel10k + plugins"

# ── Zsh ────────────────────────────────────────────────────────────────────────
if has zsh; then
    success "zsh already installed: $(zsh --version)"
else
    info "Installing zsh..."
    sudo apt-get install -y zsh -qq
    success "zsh installed"
fi

# Set as default shell
ZSH_PATH=$(which zsh)
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
    success "zsh is already the default shell"
else
    info "Setting zsh as default shell..."
    # Ensure zsh is listed in /etc/shells (required by usermod)
    grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    sudo usermod -s "$ZSH_PATH" "$USER"
    success "Default shell set to zsh (takes effect on next login)"
fi

# ── Oh My Zsh ──────────────────────────────────────────────────────────────────
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
else
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Oh My Zsh installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── Powerlevel10k ──────────────────────────────────────────────────────────────
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    success "Powerlevel10k already installed"
else
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    success "Powerlevel10k installed"
fi

# ── Plugins ────────────────────────────────────────────────────────────────────
install_omz_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$ZSH_CUSTOM/plugins/$name"
    if [[ -d "$dest" ]]; then
        info "  plugin $name already installed"
    else
        info "  cloning plugin $name..."
        git clone --depth=1 "$repo" "$dest"
        success "  plugin $name installed"
    fi
}

install_omz_plugin "zsh-autosuggestions"   "https://github.com/zsh-users/zsh-autosuggestions"
install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
install_omz_plugin "zsh-completions"       "https://github.com/zsh-users/zsh-completions"

# autojump is installed via apt in step 01
# fzf plugin comes with oh-my-zsh
# colored-man-pages, copypath, copyfile, history-substring-search, sudo → built-in OMZ plugins

success "All Zsh plugins installed"

# ── Powerlevel10k config (~/.p10k.zsh) ────────────────────────────────────────
# Only write if not already present (so user customisations are preserved)
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
    info "Writing ~/.p10k.zsh (Catppuccin Mocha lean theme)..."
    cat > "$HOME/.p10k.zsh" << 'EOF'
# Powerlevel10k config — lean style, Catppuccin Mocha
# To regenerate interactively: p10k configure

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

{
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon dir vcs newline prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status command_execution_time virtualenv pyenv
    node_version go_version rust_version
    kubecontext terraform aws background_jobs time
  )

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=240
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS_BACKGROUND=''

  local CAT_TEXT='#cdd6f4'
  local CAT_BLUE='#89b4fa'
  local CAT_GREEN='#a6e3a1'
  local CAT_YELLOW='#f9e2af'
  local CAT_RED='#f38ba8'
  local CAT_MAUVE='#cba6f7'
  local CAT_TEAL='#94e2d5'
  local CAT_PEACH='#fab387'
  local CAT_SUBTEXT='#a6adc8'
  local CAT_OVERLAY='#6c7086'

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$CAT_BLUE
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=

  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$CAT_BLUE
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$CAT_SUBTEXT
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$CAT_TEXT
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=''
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=60
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$CAT_GREEN
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$CAT_YELLOW
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$CAT_PEACH
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=5

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=$CAT_GREEN
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=$CAT_RED
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND=$CAT_BLUE
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_FOREGROUND=$CAT_MAUVE
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$CAT_RED
  typeset -g POWERLEVEL9K_STATUS_BACKGROUND=

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$CAT_YELLOW
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$CAT_TEAL
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$CAT_TEAL
  typeset -g POWERLEVEL9K_PYENV_BACKGROUND=
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true

  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$CAT_GREEN
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$CAT_BLUE
  typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=$CAT_PEACH
  typeset -g POWERLEVEL9K_RUST_VERSION_BACKGROUND=
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true

  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kubeadm|velero|k9s|stern|kubeseal|skaffold|flux|fluxctl'
  typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=$CAT_MAUVE
  typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND=

  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_ON_COMMAND='terraform|terragrunt|packer'
  typeset -g POWERLEVEL9K_TERRAFORM_FOREGROUND=$CAT_MAUVE
  typeset -g POWERLEVEL9K_TERRAFORM_BACKGROUND=

  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk'
  typeset -g POWERLEVEL9K_AWS_FOREGROUND=$CAT_PEACH
  typeset -g POWERLEVEL9K_AWS_BACKGROUND=

  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$CAT_OVERLAY
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$CAT_YELLOW
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=false

} always {
  eval "builtin setopt ${p10k_config_opts[*]}"
}
EOF
    success "~/.p10k.zsh written"
else
    success "~/.p10k.zsh already exists, skipping"
fi

# ── ~/.zshrc ──────────────────────────────────────────────────────────────────
# Only write if it doesn't already contain our setup (preserves customisations)
if grep -q "DEV_PROFILE" "$HOME/.zshrc" 2>/dev/null; then
    success "~/.zshrc already configured, skipping"
else
    info "Writing ~/.zshrc..."
    cat > "$HOME/.zshrc" << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════════
#  ~/.zshrc — Main Zsh Configuration
#  Profiles: sre | dba | python | frontend | backend
#  Set DEV_PROFILE env var or use: switch-profile
# ═══════════════════════════════════════════════════════════════════════════════

# ── Welcome message (must be BEFORE instant prompt) ───────────────────────────
if [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
  echo ""
  echo "  $(hostname) | $(date '+%a %d %b %H:%M')  | profile: ${DEV_PROFILE:-none}"
  echo "  Use 'switch-profile' or 'sp' to load a dev profile"
  echo ""
fi

# ── Powerlevel10k instant prompt ──────────────────────────────────────────────
# Must come after any intentional console output (e.g. welcome message above).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Path ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/scripts:$PATH"

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY EXTENDED_HISTORY

# ── Oh My Zsh Plugins ─────────────────────────────────────────────────────────
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  autojump
  fzf
  colored-man-pages
  copypath
  copyfile
  history-substring-search
  aliases
  sudo
)

source "$ZSH/oh-my-zsh.sh" 2>/dev/null || true

# ── Completions ───────────────────────────────────────────────────────────────
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --multi --layout=reverse --border --height=60%
  --bind='ctrl-/:toggle-preview'
"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d'

# ── zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ── bat ───────────────────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin Mocha"
if command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# ── delta ─────────────────────────────────────────────────────────────────────
if command -v delta &>/dev/null; then
  export GIT_PAGER="delta"
fi

# ── Editor ────────────────────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'

# ── Locale ────────────────────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --git --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias lt3='eza --tree --icons --level=3'
alias llt='eza -la --tree --icons --level=2'

if command -v bat &>/dev/null;  then alias cat='bat'; fi
if command -v rg  &>/dev/null;  then alias grep='rg'; fi
if command -v fd  &>/dev/null;  then alias find='fd'; fi
if command -v btop &>/dev/null; then alias top='btop'; fi
if command -v duf  &>/dev/null; then alias df='duf'; fi
if command -v dust &>/dev/null; then alias du='dust'; fi

alias gs='git status'  ga='git add'  gc='git commit'  gco='git checkout'
alias gcb='git checkout -b'  gp='git push'  gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'  gds='git diff --staged'  gb='git branch'  gba='git branch -a'
alias grb='git rebase'  gst='git stash'  gstp='git stash pop'
alias gclean='git clean -fd'  groot='cd $(git rev-parse --show-toplevel)'

alias vim='nvim' vi='nvim' v='nvim'
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'
alias aliases='alias | bat -l bash --style=plain 2>/dev/null || alias'
alias myip='curl -s ifconfig.me && echo'
alias localip="ip route get 1 | awk '{print \$7}'"
alias ports='ss -tulpn'
alias psg='ps aux | rg'
alias diskuse='duf'  sysinfo='btop'
alias mkd='mkdir -pv'  cpv='cp -v'  mvv='mv -v'  rmv='rm -v'
alias h='history | tail -50'
alias path='echo $PATH | tr ":" "\n"'
alias rm='rm -I'  cp='cp -i'  mv='mv -i'
alias ping='ping -c 5'  wget='wget -c'
alias ..='cd ..'  ...='cd ../..'  ....='cd ../../..'

# ── Functions ─────────────────────────────────────────────────────────────────
mkcd()   { mkdir -p "$1" && cd "$1"; }
fif()    { rg --files-with-matches --no-messages "$1" | fzf --preview "bat --color=always {} | rg -n '$1'"; }
fcd()    { cd "$(fd --type d | fzf --preview 'eza --tree --level=1 {}')"; }
fo()     { local f; f=$(fzf --preview 'bat --color=always {}') && ${EDITOR:-nvim} "$f"; }
gfb()    { git checkout "$(git branch --all | fzf | tr -d ' ')"; }
fkill()  { local p; p=$(ps -ef | sed 1d | fzf -m | awk '{print $2}'); [[ -n "$p" ]] && echo "$p" | xargs kill "${1:--9}"; }

extract() {
  [[ -f "$1" ]] || { echo "'$1' is not a valid file"; return 1; }
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;; *.tar.gz)  tar xzf "$1" ;; *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;; *.rar)     unrar x "$1" ;; *.gz)      gunzip "$1"   ;;
    *.tar)     tar xf "$1"  ;; *.tbz2)    tar xjf "$1" ;; *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1"   ;; *.Z)       uncompress "$1" ;; *.7z)    7z x "$1"    ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
  esac
}

# ── Profile Selector ──────────────────────────────────────────────────────────
switch-profile() {
  local profile
  profile=$(printf "sre\ndba\npython\nfrontend\nbackend\nnone" | \
    fzf --prompt="Select DEV profile: " \
        --header="Current: ${DEV_PROFILE:-none}" \
        --height=~10 --border=rounded)
  if [[ -n "$profile" ]] && [[ "$profile" != "none" ]]; then
    export DEV_PROFILE="$profile"
    [[ -f "$HOME/.zsh/profiles/$profile.zsh" ]] && source "$HOME/.zsh/profiles/$profile.zsh"
    echo "  Profile loaded: $profile"
  elif [[ "$profile" == "none" ]]; then
    unset DEV_PROFILE
    echo "  No profile active"
  fi
}
alias sp='switch-profile'

# ── Auto-load Profile ─────────────────────────────────────────────────────────
if [[ -n "${DEV_PROFILE:-}" ]] && [[ -f "$HOME/.zsh/profiles/$DEV_PROFILE.zsh" ]]; then
  source "$HOME/.zsh/profiles/$DEV_PROFILE.zsh"
fi

# ── Powerlevel10k config ──────────────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── pipx ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
EOF
    success "~/.zshrc written"
fi
