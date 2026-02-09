#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# Install zsh
if command -v zsh &>/dev/null; then
    log "zsh already installed"
else
    echo "Installing zsh..."
    if [[ "$(uname)" == "Darwin" ]]; then
        brew install zsh
    else
        sudo apt-get install -y -qq zsh
    fi
    log "zsh installed"
fi

# Install oh-my-zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already installed"
else
    echo "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    log "oh-my-zsh installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    log "zsh-autosuggestions already installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    log "zsh-autosuggestions installed"
fi

# Install zsh-syntax-highlighting
if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    log "zsh-syntax-highlighting already installed"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    log "zsh-syntax-highlighting installed"
fi

# Symlink .zshrc
if [[ -L "$HOME/.zshrc" ]] && [[ "$(readlink "$HOME/.zshrc")" == "$DOTFILES_DIR/config/.zshrc" ]]; then
    log ".zshrc already symlinked"
else
    [[ -f "$HOME/.zshrc" ]] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
    ln -sf "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"
    log ".zshrc symlinked"
fi

# Set zsh as default shell
if [[ "$(uname)" == "Darwin" ]]; then
    current_shell=$(dscl . -read /Users/"$USER" UserShell | awk '{print $2}')
else
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
fi

if [[ "$current_shell" == *"zsh"* ]]; then
    log "zsh is already the default shell"
else
    echo "Setting zsh as default shell (requires password)..."
    chsh -s "$(which zsh)"
    log "Default shell changed to zsh"
fi
