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

# Set name and email if not configured
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    read -rp "Enter your Git name: " git_name
    git config --global user.name "$git_name"
fi

if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    read -rp "Enter your Git email: " git_email
    git config --global user.email "$git_email"
fi

# Sensible defaults
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor nvim

log "Git configured: $(git config --global user.name) <$(git config --global user.email)>"
