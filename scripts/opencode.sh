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

if command -v opencode &>/dev/null; then
    log "OpenCode already installed"
else
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    log "OpenCode installed"
fi

# Symlink config
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config/opencode/opencode.json"
CONFIG_DST="$HOME/.config/opencode/opencode.json"

if [[ -L "$CONFIG_DST" ]] && [[ "$(readlink "$CONFIG_DST")" == "$CONFIG_SRC" ]]; then
    log "OpenCode config already symlinked"
else
    mkdir -p "$HOME/.config/opencode"
    [[ -e "$CONFIG_DST" ]] && mv "$CONFIG_DST" "$CONFIG_DST.backup.$(date +%s)"
    ln -sf "$CONFIG_SRC" "$CONFIG_DST"
    log "OpenCode config symlinked: $CONFIG_DST → $CONFIG_SRC"
fi

# Ensure bun is installed and in PATH
if [[ -d "$HOME/.bun/bin" ]]; then
    export PATH="$HOME/.bun/bin:$PATH"
fi

if ! command -v bun &>/dev/null; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    log "bun installed"
fi

# Install oh-my-opencode plugin
bunx oh-my-opencode install --no-tui --claude=max20 --openai=yes --gemini=no --copilot=no
log "oh-my-opencode configured"
