# Step 01 — System Dependencies

**Script:** `steps/01-system.sh`

Installs all base apt packages required by the rest of the setup. This is always the first step.

---

## What it does

1. Runs `apt-get update` to refresh package lists.
2. Installs a curated list of base packages with `apt-get install -y`.
3. Installs `tldr` (via `pipx` or apt as a fallback).

## Packages installed

### Build essentials
| Package | Purpose |
|---------|---------|
| `build-essential` | gcc, make, and related compilers |
| `curl`, `wget` | HTTP downloaders |
| `git` | Version control |
| `unzip`, `zip`, `tar` | Archive tools |
| `gnupg`, `ca-certificates` | GPG and TLS |
| `software-properties-common` | `add-apt-repository` support |
| `apt-transport-https` | HTTPS apt sources |

### Shell
| Package | Purpose |
|---------|---------|
| `zsh` | Z shell (configured in step 04) |

### Core tools
| Package | Purpose |
|---------|---------|
| `fzf` | Fuzzy finder (apt version; step 05 may install a newer one) |
| `autojump` | Directory jump via `j` command |

### Network / HTTP
| Package | Purpose |
|---------|---------|
| `httpie` | Human-friendly HTTP CLI (`http` command) |

### JSON / YAML
| Package | Purpose |
|---------|---------|
| `jq` | JSON processor |

### System monitoring
| Package | Purpose |
|---------|---------|
| `btop` | Modern process/resource monitor |
| `tmux` | Terminal multiplexer (configured in step 06) |

### Desktop / clipboard
| Package | Purpose |
|---------|---------|
| `xclip` | Clipboard CLI tool |
| `xdotool` | X11 input simulation |
| `duf` | Modern `df` replacement |

### Build dependencies
These are required by pyenv, asdf, and other language version managers:

`libssl-dev`, `zlib1g-dev`, `libbz2-dev`, `libreadline-dev`, `libsqlite3-dev`, `libncursesw5-dev`, `xz-utils`, `tk-dev`, `libxml2-dev`, `libxmlsec1-dev`, `libffi-dev`, `liblzma-dev`

### Extras
| Package | Purpose |
|---------|---------|
| `redis-tools` | Provides `redis-cli` |
| `python3-pip`, `python3-venv`, `python3-dev`, `pipx` | Python base tooling |

### tldr
Installed via `pipx install tldr` (preferred) or `apt-get install tldr` as a fallback. Provides community-maintained, simplified man pages.

---

## Files modified

None — this step only installs system packages.

## Progress key

`01-system.sh` is written to `~/.dev-setup.progress` on success.
