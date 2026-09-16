#!/usr/bin/env bash
#
# bootstrap.sh — installs required packages and symlinks this repo's
# configs into place via GNU Stow. Safe to re-run.
#
# Adding a new tool to the stack:
#   1. add its apt package name to the APT_PACKAGES array below
#   2. drop its config into a new top-level folder here, mirroring
#      the path it needs under $HOME (e.g. foo/.config/foo/config)
#   That's it — step 2 needs no edits here; every top-level folder
#   in the repo is auto-discovered as a stow package.
#
# Usage: ./bootstrap.sh   (run from anywhere; it locates the repo itself)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# System packages required by this dotfiles setup. Add/remove entries here —
# nothing else in the script needs to change to match.
APT_PACKAGES=(git tmux neovim stow)

# every top-level folder in the repo (bash, nvim, tmux, ...) is a stow package
mapfile -t STOW_PACKAGES < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '.git' -printf '%f\n')

# ---- 1. install packages -------------------------------------------------
echo "==> Installing packages: ${APT_PACKAGES[*]}"
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y "${APT_PACKAGES[@]}"
else
    echo "Unsupported package manager — install these manually: ${APT_PACKAGES[*]}" >&2
    exit 1
fi

# ---- 2. symlink dotfiles into place via stow ------------------------------
cd "$DOTFILES_DIR"

echo "==> Backing up existing ~/.bashrc..."
if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc"
    echo "    saved to $BACKUP_DIR/.bashrc"
fi

echo "==> Adopting any pre-existing real dotfiles..."
# --adopt moves conflicting real files (e.g. Ubuntu's stock ~/.bashrc) INTO
# the repo instead of stow erroring out on them. We immediately discard
# that adopted content so the repo's tracked version wins — the .bashrc
# backup above is the one exception we've made a copy of on purpose.
stow --adopt -v -t "$HOME" "${STOW_PACKAGES[@]}"
git checkout -- .

echo "==> Stowing dotfiles..."
stow -v -t "$HOME" "${STOW_PACKAGES[@]}"

echo "==> Done. Run: source ~/.bashrc"
