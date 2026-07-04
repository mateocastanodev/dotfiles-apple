#!/usr/bin/env bash
#
# dotfiles-apple — bootstrap for a fresh MacBook (Apple Silicon).
#
# Idempotent: safe to run multiple times.
# Usage:  cd ~/dotfiles-apple && ./install.sh
#
# Installs: Homebrew + CLI tools, Neovim (+plugins), tmux, Ghostty,
# oh-my-zsh, nvm + node, toolchains (Go, Python/pyenv, gcloud, Android),
# the mobile stack (React Native: watchman, cocoapods, openjdk, Android SDK),
# and creates the dotfile symlinks with GNU Stow.
#
# Does NOT install the `pi` CLI (Claude Code is used instead).
set -uo pipefail

# ── logging ────────────────────────────────────────────────────────────────
bold() { printf "\033[1m%s\033[0m\n" "$*"; }
info() { printf "\033[1;34m›\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!\033[0m %s\n" "$*"; }
step() { printf "\n\033[1;35m══ %s\033[0m\n" "$*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is macOS only." >&2; exit 1
fi

# ── 1. Xcode Command Line Tools ────────────────────────────────────────────
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode CLT already installed"
else
  warn "Installing Xcode CLT (a system dialog will open)..."
  xcode-select --install || true
  echo "  Finish the install in the dialog, then re-run this script."
  read -r -p "  Press Enter once the dialog is done... " _
fi

# ── 2. Homebrew ────────────────────────────────────────────────────────────
step "Homebrew"
if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  info "Installing Homebrew (will ask for your macOS password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
ok "$(brew --version | head -1)"

# Put brew on the PATH for future shells (goes in ~/.zprofile, NOT managed by stow)
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  printf '\n# Homebrew\neval "$(/opt/homebrew/bin/brew shellenv)"\n' >> "$HOME/.zprofile"
  ok "brew shellenv added to ~/.zprofile"
fi

# ── 3. Homebrew formulae ───────────────────────────────────────────────────
step "Homebrew formulae"
FORMULAE=(
  git gh stow                                       # base
  tmux ripgrep fd fzf lazygit                       # terminal / navigation
  tree-sitter tree-sitter-cli lua-language-server   # Neovim
  uv pyenv go                                        # languages / tooling
  neovim
  watchman cocoapods openjdk                        # React Native / mobile
)
info "brew install ${FORMULAE[*]}"
brew install "${FORMULAE[@]}"
ok "Formulae installed"

# ── 4. Casks (apps and fonts) ──────────────────────────────────────────────
step "Homebrew casks"
CASKS=(
  ghostty                    # terminal
  font-fira-code             # terminal font
  google-cloud-sdk           # gcloud
  android-commandlinetools   # Android SDK base
)
info "brew install --cask ${CASKS[*]}"
brew install --cask "${CASKS[@]}"
ok "Casks installed"

# ── 5. oh-my-zsh ───────────────────────────────────────────────────────────
step "oh-my-zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "oh-my-zsh already installed"
else
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
  ok "oh-my-zsh installed"
fi

# ── 6. nvm + node ──────────────────────────────────────────────────────────
step "nvm + node"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # PROFILE=/dev/null so the installer does NOT write into the repo's .zshrc
  PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
if ! nvm which default >/dev/null 2>&1; then
  nvm install --lts
  nvm alias default 'lts/*'
fi
nvm use default >/dev/null 2>&1
ok "node $(node -v) · npm $(npm -v)"

# ── 7. Python tooling for Neovim (via uv) ──────────────────────────────────
step "Neovim Python tooling (uv)"
for tool in ty ruff debugpy; do
  uv tool install "${tool}@latest" >/dev/null 2>&1 && ok "$tool" || warn "could not install $tool"
done

# ── 8. Android SDK (React Native) ──────────────────────────────────────────
step "Android SDK"
export JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
ANDROID_SDK="$HOME/Library/Android/sdk"
if [[ -d "$ANDROID_SDK/platform-tools" ]]; then
  ok "Android SDK already present at $ANDROID_SDK"
else
  mkdir -p "$ANDROID_SDK"
  info "Accepting licenses and installing components (may take a while)..."
  yes 2>/dev/null | sdkmanager --sdk_root="$ANDROID_SDK" --licenses >/dev/null 2>&1 || true
  sdkmanager --sdk_root="$ANDROID_SDK" \
    "platform-tools" "emulator" "platforms;android-35" "build-tools;35.0.0" || \
    warn "sdkmanager finished with warnings (see above)"
  ok "Android SDK installed at $ANDROID_SDK"
fi

# ── 9. Dotfile symlinks (GNU Stow) ─────────────────────────────────────────
step "Symlinks with Stow"
# Back up a non-symlink ~/.zshrc so stow does not conflict
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.pre-stow.bak"
  warn "existing ~/.zshrc backed up to ~/.zshrc.pre-stow.bak"
fi
mkdir -p "$HOME/.config"
# Packages to stow (NOT 'pi': Claude Code is used instead)
STOW_PKGS=(neovim tmux ghostty zshrc)
( cd "$DOTFILES_DIR" && stow -v -t "$HOME" "${STOW_PKGS[@]}" )
ok "Symlinks created: ${STOW_PKGS[*]}"

# ── 10. Pre-warm Neovim plugins ────────────────────────────────────────────
step "Neovim plugins (vim.pack)"
nvim --headless "+qa" >/dev/null 2>&1 && ok "Plugins downloaded" || warn "check 'nvim' manually"

# ── Done ───────────────────────────────────────────────────────────────────
step "Done"
bold "Setup complete. Remaining manual steps (on demand):"
cat <<'EOF'
  • Open Ghostty (or restart the terminal) to load the new environment.
  • iOS/React Native: install Xcode from the App Store, then run:
        sudo xcodebuild -license accept
        xcodebuild -runFirstLaunch
  • pyenv install <version>   → when you need a specific Python
  • :TSInstall <lang>         → Treesitter parsers in Neovim, on demand
  • gcloud auth login         → to authenticate with Google Cloud
EOF
