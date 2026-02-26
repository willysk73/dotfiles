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
        ripgrep codespell tmux libclang-dev
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
        sudo apt-get update -qq 2>/dev/null || warn "apt update had errors — some repos may be stale"
        sudo dpkg --configure -a 2>/dev/null || true
        sudo apt-get -o Dpkg::Options::="--force-overwrite" -f install -y -qq 2>/dev/null || true
        sudo apt-get -o Dpkg::Options::="--force-overwrite" install -y -qq "${missing[@]}"
        log "Base packages installed"
    else
        log "Base packages already installed"
    fi
fi

# Rust / cargo (tree-sitter-cli via npm requires GLIBC_2.39+ on older Linux)
if [[ "$(uname)" != "Darwin" ]]; then
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    if command -v cargo &>/dev/null; then
        log "Rust already installed: $(rustc --version)"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env" 2>/dev/null || true
        log "Rust installed: $(rustc --version)"
    fi
fi

# fnm + Node.js (required by claude-code, tree-sitter-cli)
if command -v fnm &>/dev/null; then
    log "fnm already installed"
else
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell
    log "fnm installed"
fi

export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env 2>/dev/null)" || true

if command -v node &>/dev/null; then
    log "Node.js already installed: $(node --version)"
else
    fnm install --lts
    log "Node.js LTS installed: $(node --version)"
fi
