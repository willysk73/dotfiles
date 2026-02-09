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

SSH_KEY="$HOME/.ssh/id_ed25519"

# Generate SSH key if not present
if [[ -f "$SSH_KEY" ]]; then
    log "SSH key already exists"
else
    echo "Generating SSH key..."
    read -rp "Enter your email (for SSH key label): " email
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
    log "SSH key generated"
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add "$SSH_KEY" 2>/dev/null

# Test GitHub connectivity (ssh -T always exits 1 with GitHub, so capture output instead)
ssh_output=$(ssh -T git@github.com 2>&1 || true)
if echo "$ssh_output" | grep -q "successfully authenticated"; then
    log "GitHub SSH authentication successful"
else
    # Key not on GitHub yet — show it and wait
    echo ""
    echo -e "  ${BOLD}${CYAN}Add this public key to GitHub → Settings → SSH and GPG keys → New SSH key:${NC}"
    echo ""
    echo -e "  ${BOLD}${GREEN}$(cat "${SSH_KEY}.pub")${NC}"
    echo ""
    read -rp "Press Enter after you've added the key to GitHub..."

    # Verify again
    ssh_output=$(ssh -T git@github.com 2>&1 || true)
    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        log "GitHub SSH authentication successful"
    else
        warn "Could not verify GitHub SSH auth — check manually with: ssh -T git@github.com"
    fi
fi

# Fix init.lua remote if it uses HTTPS with a token
INIT_LUA_DIR="$HOME/repositories/init.lua"
if [[ -d "$INIT_LUA_DIR" ]]; then
    current_remote=$(git -C "$INIT_LUA_DIR" remote get-url origin 2>/dev/null || echo "")
    if [[ "$current_remote" == https://* ]]; then
        # Extract owner/repo from the URL
        repo_path=$(echo "$current_remote" | sed -E 's|https://[^/]*@?github.com/||; s|\.git$||')
        new_remote="git@github.com:${repo_path}.git"
        git -C "$INIT_LUA_DIR" remote set-url origin "$new_remote"
        log "Switched init.lua remote to SSH: $new_remote"
        warn "IMPORTANT: Revoke the leaked PAT on GitHub → Settings → Developer settings → Personal access tokens"
    else
        log "init.lua remote already uses SSH"
    fi
fi
