# Profile: Python Developer

**Script:** `steps/10-profile-python.sh`
**Flag:** `--profiles python`

Installs a complete Python development environment with version management, fast package tooling, and essential developer tools.

---

## Tools installed

### pyenv — Python version manager

Installed via `curl -fsSL https://pyenv.run | bash` into `~/.pyenv`. After installation, the latest stable Python 3 release is automatically installed and set as the global default.

```bash
pyenv install 3.x.y
pyenv global 3.x.y
pyenv versions
```

`$PYENV_ROOT` and the pyenv shims are added to `PATH` within the step script. Add to your `.zshrc` profile if you want pyenv active by default outside the profile.

### uv — ultrafast Python package manager

Installed via the official `astral.sh/uv` installer. A Rust-based drop-in replacement for `pip` and `venv` that is 10–100× faster.

```bash
uv pip install requests
uv venv .venv
uv run python script.py
```

### poetry — dependency management

Installed via the official `install.python-poetry.org` installer. Manages project dependencies, virtual environments, and package publishing.

```bash
poetry new my-project
poetry add fastapi
poetry install
poetry run python main.py
```

### ruff — Python linter and formatter

Installed via `pipx install ruff`. Extremely fast (Rust-based) Python linter and formatter, replacing flake8, isort, and portions of black.

```bash
ruff check .
ruff format .
```

### mypy — static type checker

Installed via `pipx install mypy`. Checks Python type annotations for correctness.

```bash
mypy src/
```

### ipython — enhanced interactive shell

Installed via `pipx install ipython`. A feature-rich Python REPL with tab completion, syntax highlighting, magic commands, and more.

```bash
ipython
```

### cookiecutter — project templating

Installed via `pipx install cookiecutter`. Creates project structures from templates.

```bash
cookiecutter gh:tiangolo/full-stack-fastapi-template
```

### JupyterLab

Installed via `pipx install jupyterlab`. The next-generation Jupyter notebook environment for interactive data science and scientific computing.

```bash
jupyter lab
jupyter notebook
```

---

## Notes

- All tools are installed via `pipx` to keep them isolated from each other and from project virtual environments.
- `pipx ensurepath` is run to ensure `~/.local/bin` is in `$PATH`.
- The `python` profile pairs well with the `backend` profile for full Python backend stacks.

---

## Progress key

`10-profile-python.sh` is written to `~/.dev-setup.progress` on success.
