# lib/ — Shared Library Scripts

These two scripts are sourced by every step script and by `setup.sh` itself. They must be loaded before any step logic runs.

---

## `lib/colors.sh`

Defines ANSI color variables and logging helper functions used throughout the setup.

### Color variables

| Variable | Color |
|----------|-------|
| `RED` | Red |
| `GREEN` | Green |
| `YELLOW` | Yellow (bold) |
| `BLUE` | Blue |
| `CYAN` | Cyan |
| `BOLD` | Bold (no color) |
| `NC` | Reset / No Color |

### Logging functions

| Function | Prefix | Usage |
|----------|--------|-------|
| `info "msg"` | `[INFO]` blue | Informational messages |
| `success "msg"` | `[OK]` green | Successful completion |
| `warn "msg"` | `[WARN]` yellow | Non-fatal warnings |
| `error "msg"` | `[ERR]` red (stderr) | Errors |
| `step "msg"` | `==>` bold cyan | Section/phase headers |

---

## `lib/helpers.sh`

Provides utility functions shared across all step scripts.

### `has <command>`

Returns `0` if a command exists in `$PATH`, `1` otherwise. Used everywhere as a guard before attempting installation.

```bash
has docker && echo "docker found"
```

### `apt_install <package>`

Installs an apt package only if it is not already installed. Suppresses most output; shows only errors.

```bash
apt_install curl
```

### `install_if_missing <cmd> <description> <install-command...>`

Runs an install command only when the target binary is missing from `$PATH`.

```bash
install_if_missing jq "jq JSON processor" sudo apt-get install -y jq
```

### `github_latest_url <repo> <pattern>`

Fetches the GitHub releases API for `<repo>` and returns the download URL of the first asset whose name matches `<pattern>` (grep -E).

```bash
URL=$(github_latest_url "sharkdp/bat" "x86_64-unknown-linux-gnu\.tar\.gz$")
```

### `confirm_step <message>`

Prints a `[CONFIRM]` prompt and waits for the user to press Enter (or Ctrl+C to abort). Used in `setup.sh` before each phase when running interactively.

### `step_done <name>`

Appends `<name>` to `~/.dev-setup.progress`. Called after a step completes successfully so it can be skipped on re-runs.

### `is_step_done <name>`

Returns `0` if `<name>` appears in `~/.dev-setup.progress`. Used to skip already-completed steps.

### `add_line_if_missing <file> <line>`

Appends `<line>` to `<file>` only if it is not already present — safe for idempotent shell config modifications.

```bash
add_line_if_missing ~/.zshrc 'export PATH="$HOME/.local/bin:$PATH"'
```
