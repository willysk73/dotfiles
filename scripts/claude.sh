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

if command -v claude &>/dev/null; then
    log "Claude CLI already installed"
else
    echo "Installing Claude CLI..."
    if command -v npm &>/dev/null; then
        npm install -g @anthropic-ai/claude-code
    elif command -v bun &>/dev/null; then
        bun install -g @anthropic-ai/claude-code
    else
        echo "Neither npm nor bun found — install Node.js first, then re-run"
        exit 1
    fi
    log "Claude CLI installed"
fi

# Symlink skills
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$DOTFILES_DIR/config/claude/skills"
SKILLS_DST="$HOME/.claude/skills"

if [[ -L "$SKILLS_DST" ]] && [[ "$(readlink "$SKILLS_DST")" == "$SKILLS_SRC" ]]; then
    log "Claude skills already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$SKILLS_DST" ]] && mv "$SKILLS_DST" "$SKILLS_DST.backup.$(date +%s)"
    ln -sf "$SKILLS_SRC" "$SKILLS_DST"
    log "Claude skills symlinked: $SKILLS_DST → $SKILLS_SRC"
fi

# Symlink agents
AGENTS_SRC="$DOTFILES_DIR/config/claude/agents"
AGENTS_DST="$HOME/.claude/agents"

if [[ -L "$AGENTS_DST" ]] && [[ "$(readlink "$AGENTS_DST")" == "$AGENTS_SRC" ]]; then
    log "Claude agents already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$AGENTS_DST" ]] && mv "$AGENTS_DST" "$AGENTS_DST.backup.$(date +%s)"
    ln -sf "$AGENTS_SRC" "$AGENTS_DST"
    log "Claude agents symlinked: $AGENTS_DST → $AGENTS_SRC"
fi
