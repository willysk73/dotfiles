#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$HOME/.secrets" ]]; then
    log "Secrets file already present"
else
    cp "$DOTFILES_DIR/config/.secrets.example" "$HOME/.secrets"
    chmod 600 "$HOME/.secrets"
    log "Secrets file created at ~/.secrets"
    warn "Edit ~/.secrets and fill in your credentials"
fi
