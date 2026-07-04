---
name: mac-setup
description: >-
  Set up this dotfiles repo's full development environment on a fresh MacBook
  (Apple Silicon) from scratch. Use it when the user wants to install/configure
  their whole setup — editor, terminal, shell, toolchains and the mobile stack
  (React Native / React / Go) — from this repo. Triggers on phrases like
  "set up my machine", "install everything on this laptop", "configure my new
  mac", "bootstrap dotfiles".
---

# mac-setup — bootstrap a fresh MacBook

Goal: get the machine ready to code (React, React Native and Go) **just by
cloning this repo and running this skill**. The heavy lifting is done by
`install.sh` at the repo root; this skill orchestrates the steps that require
the user (password / dialogs / login).

User profile: software and **mobile developer with React / React Native** and
**Go on the backend**. The mobile stack (watchman, cocoapods, openjdk, Android
SDK) is already covered by `install.sh`.

## Important rules

- **Do NOT install the `pi` CLI** or stow the `pi/` package. The user uses
  Claude Code. `install.sh` already skips it; don't add it.
- This is an **Apple Silicon** machine → Homebrew lives in `/opt/homebrew`.
- The script is **idempotent**: if something fails, fix it and re-run.
- You are an agent; several steps need `sudo`, a password or a browser, and you
  **cannot type the user's password**. For those, ask the user to run them
  themselves by typing `! <command>` at the start of the prompt (that runs it
  in the session so you see the result).

## Procedure

### 0. Context
- Confirm you are at the repo root (`install.sh` and the `neovim/ tmux/
  ghostty/ zshrc/` folders must exist).
- Check architecture: `uname -m` must return `arm64`.

### 1. Interactive steps (the USER runs these with `!`)
These need a password or a system dialog. Ask for them first:

1. **Xcode Command Line Tools** (if `xcode-select -p` fails):
   ```
   ! xcode-select --install
   ```
2. **Homebrew** (needs `sudo`, the agent can't do it):
   ```
   ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Once it finishes, continue with the rest (the rest does NOT need sudo).

### 2. The bulk of the install (the AGENT runs this)
With Homebrew installed, run the script. Everything below needs NO sudo:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
cd <repo-root> && ./install.sh
```
`install.sh` idempotently does:
- `brew` formulae: git, gh, stow, tmux, ripgrep, fd, fzf, lazygit,
  tree-sitter(+cli), lua-language-server, uv, pyenv, go, neovim,
  **watchman, cocoapods, openjdk** (mobile).
- `brew` casks: ghostty, font-fira-code, google-cloud-sdk,
  android-commandlinetools.
- oh-my-zsh, **nvm** + node LTS (with `PROFILE=/dev/null` so it doesn't clobber
  the repo's `.zshrc`).
- Neovim Python tooling via `uv`: ty, ruff, debugpy.
- Android SDK (platform-tools, emulator, platform-35, build-tools) at
  `~/Library/Android/sdk`.
- `brew shellenv` → `~/.zprofile` (the repo's `.zshrc` doesn't add it and on
  Apple Silicon brew isn't on the PATH by default).
- **stow** symlinks for `neovim tmux ghostty zshrc` (backing up any existing
  `~/.zshrc` to `~/.zshrc.pre-stow.bak`).
- Pre-warms the Neovim plugins (`nvim --headless "+qa"`).

If you want more granularity (or something in the script fails), you can run
those sections by hand — they're clearly separated in `install.sh`.

### 3. Verification
Check everything landed (each should print a version with no error):
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"; nvm use default >/dev/null
export PATH="$HOME/.local/bin:$PATH"
nvim --version | head -1;  tmux -V;  stow --version | head -1
rg --version | head -1;  fd --version;  fzf --version;  lazygit --version
node -v; npm -v; go version; pyenv --version; gcloud --version | head -1
watchman --version; pod --version
~/Library/Android/sdk/platform-tools/adb --version | head -1
ty --version; ruff --version
for f in ~/.zshrc ~/.tmux.conf ~/.config/nvim ~/.config/ghostty; do readlink "$f"; done
```
- `zsh -i -c 'echo ok'` must load `.zshrc` with no real errors (a
  `can't change option: zle` notice outside a real terminal is harmless).
- `nvim --headless "+checkhealth" "+qa"`: only optional WARNINGs are expected
  (icons, on-demand treesitter parsers, node/perl/python/ruby providers), no
  ERROR.

### 4. Final manual steps (tell the user about them)
- Open **Ghostty** (or restart the terminal) to load the new environment.
- **iOS / React Native**: install **Xcode** from the App Store, then:
  `sudo xcodebuild -license accept` and `xcodebuild -runFirstLaunch`.
- `pyenv install <version>` when a specific Python is needed.
- `:TSInstall <lang>` for Treesitter parsers (on demand).
- `gcloud auth login` to authenticate with Google Cloud.

## Maintenance notes
- If you add a new app/tool, add it to `install.sh` (formula, cask or a
  dedicated step) so the bootstrap stays a single command.
- For a new dotfile: put it in the repo mirroring `~`, add the package to
  `STOW_PKGS` in `install.sh`, and run `stow <package>`.
