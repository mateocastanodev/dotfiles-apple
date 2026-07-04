# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load 
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="$HOME/.local/bin:$PATH"

# go commands for the cli to work
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# Expo development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# The next line updates PATH for the Google Cloud SDK (installed via Homebrew cask).
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# File searching fzf + fd
command -v fzf >/dev/null && source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --exclude .git --exclude Library'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --exclude .git --exclude Library'
# Theme Created with https://vitormv.github.io/fzf-themes/
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#9f9e99,fg+:#a7d8b0,bg:#101113,bg+:#101113
  --color=hl:#9f9e99,hl+:#a7d8b0,info:#787487,marker:#87ff00
  --color=prompt:#9f9e99,spinner:#83799C,pointer:#af5fff,header:#6D7580
  --color=border:#262626,label:#9a9a9a,query:#9f9e99,disabled:#9f9e99
  --preview-window="border-sharp" --padding="1" --margin="1" --prompt="> "
  --marker="" --pointer="" --separator="─" --scrollbar="│"
  --layout="reverse"'

alias vim=nvim
alias venv="source .venv/bin/activate"

# set default editor
export EDITOR=nvim
export VISUAL=nvim

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Useful aliases
alias cpwd='pwd | tr -d "\n" | pbcopy'

# Pi

# Lazy-load nvm for faster shell startup.
# nvm is only loaded when one of these commands is first used.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx pi
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}

nvm() {
  _load_nvm
  nvm "$@"
}

node() {
  _load_nvm
  node "$@"
}

npm() {
  _load_nvm
  npm "$@"
}

npx() {
  _load_nvm
  npx "$@"
}

pi() {
  _load_nvm
  pi "$@"
}
