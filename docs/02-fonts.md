# Step 02 — Nerd Fonts

**Script:** `steps/02-fonts.sh`

Downloads and installs **JetBrains Mono Nerd Font** — the font used by Ghostty, the Powerlevel10k prompt, and Neovim icons.

---

## What it does

1. Checks if the font is already installed via `fc-list | grep -qi "JetBrainsMono Nerd"` — skips if found.
2. Fetches the latest release ZIP from the `ryanoasis/nerd-fonts` GitHub repository.
   Falls back to a pinned URL (`v3.3.0`) if the API call fails.
3. Extracts all `.ttf` files into `~/.local/share/fonts/JetBrainsMonoNF/`.
4. Refreshes the font cache with `fc-cache`.

---

## Install location

```
~/.local/share/fonts/JetBrainsMonoNF/
```

## Why JetBrains Mono Nerd Font?

- Excellent ligature support (`calt`, `liga`, `ss01`, `ss02`, `ss19`, `ss20`)
- Full Nerd Font icon coverage (used by `eza --icons`, Powerlevel10k, Neovim `nvim-web-devicons`)
- Configured as the Ghostty font in `step 03`

---

## Progress key

`02-fonts.sh` is written to `~/.dev-setup.progress` on success.
