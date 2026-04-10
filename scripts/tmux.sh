#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# Symlink tmux config
CONFIG_SRC="$DOTFILES_DIR/config/tmux/tmux.conf"
CONFIG_DST="$HOME/.tmux.conf"

if [[ -L "$CONFIG_DST" ]] && [[ "$(readlink "$CONFIG_DST")" == "$CONFIG_SRC" ]]; then
    log "tmux config already symlinked"
else
    [[ -e "$CONFIG_DST" ]] && mv "$CONFIG_DST" "$CONFIG_DST.backup.$(date +%s)"
    ln -sf "$CONFIG_SRC" "$CONFIG_DST"
    log "tmux config symlinked: $CONFIG_DST → $CONFIG_SRC"
fi
