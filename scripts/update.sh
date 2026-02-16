#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
header() { echo -e "\n${BOLD}${CYAN}▸ $1${NC}"; echo -e "${DIM}  ─────────────────────────────${NC}"; }

header "System packages"
if [[ "$(uname)" == "Darwin" ]]; then
    brew update && brew upgrade
else
    sudo apt-get update -qq && sudo apt-get upgrade -y -qq
fi
log "System packages updated"

header "Dotfiles"
git -C "$HOME/dotfiles" pull --quiet
log "Dotfiles updated"

header "Neovim config"
git -C "$HOME/repositories/init.lua" pull --quiet
log "init.lua updated"

header "Obsidian vault"
git -C "$HOME/obsidian-vault" pull --quiet
log "Obsidian vault updated"

header "Neovim plugins"
nvim --headless -c 'Lazy sync' -c 'qa' 2>/dev/null
log "Neovim plugins updated"

header "Oh My Zsh"
ZSH="$HOME/.oh-my-zsh" command zsh -c 'source $ZSH/oh-my-zsh.sh && omz update --unattended' 2>/dev/null || true
log "Oh My Zsh updated"

header "npm global packages"
if command -v npm &>/dev/null; then
    npm update -g --silent 2>/dev/null
    log "npm packages updated"
else
    warn "npm not found, skipping"
fi

echo ""
log "Everything up to date!"
