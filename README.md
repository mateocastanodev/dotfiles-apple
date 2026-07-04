# dotfiles-apple

My macOS (Apple Silicon) coding setup: **Neovim, tmux, Ghostty and zsh**, plus
the **React / React Native / Go** toolchains. Managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## 🚀 Setup on a new laptop

**Option A — with Claude Code (recommended):**

```bash
git clone git@github.com:mateocastanodev/dotfiles-apple.git ~/dotfiles-apple
cd ~/dotfiles-apple
claude
```

Then ask: *"set up this laptop"*. Claude uses the
[`mac-setup`](.claude/skills/mac-setup/SKILL.md) skill and runs the whole
install (it will ask you to run the `sudo` steps yourself, like Homebrew).

**Option B — by hand:**

```bash
git clone git@github.com:mateocastanodev/dotfiles-apple.git ~/dotfiles-apple
cd ~/dotfiles-apple
./install.sh
```

`install.sh` is idempotent (safe to re-run) and sets everything up.

## 📦 What it installs

| Category | Tools |
|---|---|
| **Editor** | Neovim 0.12+ (native config with `vim.pack`), tree-sitter, lua-language-server |
| **Terminal / shell** | Ghostty + Fira Code, tmux, zsh + oh-my-zsh, fzf, fd, ripgrep, lazygit |
| **Node** | nvm + Node LTS |
| **Go** | go |
| **Python** | pyenv · uv (ty, ruff, debugpy for Neovim) |
| **Mobile (RN)** | watchman, cocoapods, openjdk, Android SDK (`~/Library/Android/sdk`) |
| **Cloud** | Google Cloud SDK |
| **Dotfiles** | symlinks via GNU Stow |

> The `pi` CLI is **not** installed (Claude Code is used instead). Its files
> stay in `pi/` in case they're wanted later.

## 🗂 Structure

```
dotfiles-apple/
├── install.sh                     # one-command bootstrap
├── .claude/skills/mac-setup/      # Claude Code skill (runbook)
├── neovim/.config/nvim/
├── tmux/.tmux.conf
├── ghostty/.config/ghostty/
├── zshrc/.zshrc
└── pi/.pi/agent/                  # pi config (not installed)
```

## ➕ Adding a new config

1. Move the file/folder into the repo, mirroring the `~` structure.
2. Add the package to `STOW_PKGS` in `install.sh`.
3. Run `stow <package>` to create the symlink, and commit.

## Requirements

macOS (Apple Silicon). Everything else is installed by `install.sh` / the
skill, starting with Homebrew.
