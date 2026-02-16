#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

OBSIDIAN_VAULT="$HOME/obsidian-vault"

# Clone vault repo if missing
if [[ -d "$OBSIDIAN_VAULT" ]]; then
    log "Obsidian vault already present"
else
    git clone git@github.com:willysk73/obsidian-vault.git "$OBSIDIAN_VAULT"
    log "Obsidian vault cloned"
fi
