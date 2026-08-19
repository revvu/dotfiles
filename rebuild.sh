#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# Absolute path: sudo resets PATH to secure_path, which doesn't include
# nix-darwin's bin, so a bare `sudo darwin-rebuild` is "command not found".
exec sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#mac
