#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }
header() { echo -e "\n${BOLD}${CYAN}▸ $1${NC}"; echo -e "${DIM}  ─────────────────────────────${NC}"; }

# Lightweight check mode — called on login
if [[ "${1:-}" == "--check" ]]; then
    # Pull latest dotfiles
    cd "$DOTFILES_DIR"
    if git pull --quiet 2>/dev/null; then
        : # silently up to date
    fi

    # Verify key tools exist
    missing=()
    for cmd in git nvim zsh ssh curl; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Missing tools: ${missing[*]} — run ~/dotfiles/install.sh to fix"
    fi
    exit 0
fi

echo ""
echo -e "${BOLD}${MAGENTA}  ╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}${MAGENTA}  ║   ${CYAN}Dotfiles Bootstrap Installer${MAGENTA}   ║${NC}"
echo -e "${BOLD}${MAGENTA}  ╚══════════════════════════════════╝${NC}"

declare -A labels=(
    [tools.sh]="Base Packages"
    [ssh.sh]="SSH Keys"
    [git.sh]="Git Config"
    [zsh.sh]="Zsh Shell"
    [neovim.sh]="Neovim"
    [obsidian.sh]="Obsidian Vault"
    [claude.sh]="Claude CLI"
)

for script in tools.sh ssh.sh git.sh zsh.sh neovim.sh obsidian.sh claude.sh; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        header "${labels[$script]}"
        bash "$SCRIPTS_DIR/$script"
    fi
done

echo ""
echo -e "${BOLD}${GREEN}  ╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}  ║         All done! 🎉             ║${NC}"
echo -e "${BOLD}${GREEN}  ╚══════════════════════════════════╝${NC}"
echo -e "  Restart your shell or run: ${BOLD}exec zsh${NC}"
echo ""
