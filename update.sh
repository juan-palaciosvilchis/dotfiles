#!/usr/bin/env bash
#
# update.sh — (re)link every package folder in this repo into $HOME.
# Safe to re-run any time you add, remove, or rename a file inside a
# package. Never touches git, never adopts or overwrites a real file —
# if something's in the way, stow reports it and that package is skipped.
#
# Usage: ./update.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

mapfile -t STOW_PACKAGES < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
    -not -name '.git' -printf '%f\n')

echo "==> Packages: ${STOW_PACKAGES[*]}"

FAILED=()
for pkg in "${STOW_PACKAGES[@]}"; do
    echo "---- $pkg ----"
    if ! stow -R -v -t "$HOME" "$pkg"; then
        FAILED+=("$pkg")
    fi
done

if [ ${#FAILED[@]} -gt 0 ]; then
    echo
    echo "==> Conflicts, not linked: ${FAILED[*]}"
    echo "    A real (non-symlink) file exists at the target."
    echo "    Move it aside or delete it, then re-run this script."
    exit 1
fi

echo "==> Done."
