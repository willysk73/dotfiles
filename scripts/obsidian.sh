#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

OBSIDIAN_VAULT="$HOME/obsidian-vault"

OBSIDIAN_REPO="git@github.com:willysk73/obsidian-vault.git"

# Clone vault repo if missing
if [[ -d "$OBSIDIAN_VAULT" ]]; then
    log "Obsidian vault already present"
else
    mapfile -t branches < <(git ls-remote --heads "$OBSIDIAN_REPO" | awk -F'refs/heads/' '{print $2}')

    if [[ ${#branches[@]} -eq 0 ]]; then
        warn "No branches found, cloning default branch"
        git clone "$OBSIDIAN_REPO" "$OBSIDIAN_VAULT"
    elif [[ ${#branches[@]} -eq 1 ]]; then
        git clone -b "${branches[0]}" "$OBSIDIAN_REPO" "$OBSIDIAN_VAULT"
        log "Obsidian vault cloned (branch: ${branches[0]})"
    else
        echo ""
        echo -e "  ${YELLOW}Available branches:${NC}"
        for i in "${!branches[@]}"; do
            echo -e "    $((i + 1))) ${branches[$i]}"
        done
        echo ""
        read -rp "  Select branch [1-${#branches[@]}]: " choice

        if [[ "$choice" -ge 1 && "$choice" -le ${#branches[@]} ]] 2>/dev/null; then
            selected="${branches[$((choice - 1))]}"
        else
            selected="${branches[0]}"
            warn "Invalid choice, using ${selected}"
        fi

        git clone -b "$selected" "$OBSIDIAN_REPO" "$OBSIDIAN_VAULT"
        log "Obsidian vault cloned (branch: ${selected})"
    fi
fi
