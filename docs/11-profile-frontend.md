# Profile: Frontend Developer

**Script:** `steps/11-profile-frontend.sh`
**Flag:** `--profiles frontend`

Installs Node.js version management and the modern JavaScript/TypeScript toolchain for frontend developers.

---

## Tools installed

### nvm — Node Version Manager

Installed via the official nvm install script (version detected from GitHub releases, falls back to `v0.40.1`). Installed into `~/.nvm`.

```bash
nvm install --lts
nvm install 22
nvm use 20
nvm alias default lts/*
nvm ls
```

### Node.js LTS

After nvm is installed, the latest LTS release of Node.js is automatically installed and set as the default alias:

```bash
node --version
npm --version
```

### pnpm — fast package manager

Installed via `npm install -g pnpm` or the official `get.pnpm.io` script. A disk-efficient package manager that uses hard links to avoid duplicating node_modules.

```bash
pnpm install
pnpm add react
pnpm run dev
pnpm dlx create-next-app@latest
```

`$PNPM_HOME` is added to `PATH`.

### bun — all-in-one JS runtime and toolkit

Installed via the official `bun.sh/install` script into `~/.bun`. A fast JavaScript runtime, package manager, test runner, and bundler in one.

```bash
bun install
bun add hono
bun run dev
bun test
bun build src/index.ts --outdir dist
```

`$BUN_INSTALL/bin` is added to `PATH`.

### Global pnpm packages

Installed globally via pnpm (falls back to npm):

| Package | Purpose |
|---------|---------|
| `npm-check-updates` | Check and update `package.json` dependencies (`ncu`) |
| `prettier` | Opinionated code formatter |
| `eslint` | JavaScript/TypeScript linter |

### Vercel CLI

Installed via `pnpm add -g vercel` if not already present.

```bash
vercel deploy
vercel dev
vercel env pull
```

### Netlify CLI

Installed via `pnpm add -g netlify-cli` if not already present.

```bash
netlify dev
netlify deploy
netlify functions:invoke
```

---

## Notes

- nvm uses unbound variables internally; the script temporarily disables `set -u` when sourcing nvm.
- The nvm shell integration is automatically added to `.zshrc` by nvm's own installer — load it with `source ~/.nvm/nvm.sh` in your session if needed before the profile is sourced.

---

## Progress key

`11-profile-frontend.sh` is written to `~/.dev-setup.progress` on success.
