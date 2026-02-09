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

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS — use Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        log "Homebrew installed"
    fi

    PACKAGES=(curl git unzip python3 ripgrep codespell lua luarocks tmux)

    missing=()
    for pkg in "${PACKAGES[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Installing: ${missing[*]}"
        brew install "${missing[@]}"
        log "Base packages installed"
    else
        log "Base packages already installed"
    fi
else
    # Linux — use apt
    PACKAGES=(
        curl git unzip build-essential software-properties-common
        python3 python3-venv python3-pip
        ripgrep codespell tmux
        lua5.4 luarocks
    )

    missing=()
    for pkg in "${PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Installing: ${missing[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y -qq "${missing[@]}"
        log "Base packages installed"
    else
        log "Base packages already installed"
    fi
fi
