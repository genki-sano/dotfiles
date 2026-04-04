#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLAKE_DIR="$DOTFILES_DIR/.config/nix"
LOCAL_NIX="$FLAKE_DIR/local.nix"
LOCAL_NIX_EXAMPLE="$FLAKE_DIR/local.nix.example"
DRY_RUN=false
AUTO_YES=false

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [-n|--dry-run] [-y|--yes]
  -n, --dry-run  Show what would change without modifying files
  -y, --yes      Skip confirmation prompt
  -h, --help     Show this help
EOF
}

ensure_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "error: bootstrap.sh is supported only on macOS" >&2
    exit 1
  fi
}

ensure_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  cat >&2 <<'EOF'
error: nix command is not installed.

Install Nix from the official download page:
  https://nixos.org/download/
EOF
  exit 1
}

run_cmd() {
  if "$DRY_RUN"; then
    echo "dry-run: $*"
  else
    "$@"
  fi
}

backup_path_if_exists() {
  local path="$1"
  local backup="$2"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return
  fi

  if [[ -e "$backup" || -L "$backup" ]]; then
    echo "info: keep existing backup: $backup"
    return
  fi

  echo "info: backup $path -> $backup"
  run_cmd mv "$path" "$backup"
}

prepare_home_manager_paths() {
  backup_path_if_exists "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.pre-home-manager"
  backup_path_if_exists "$HOME/.config/oh-my-zsh" "$HOME/.config/oh-my-zsh.pre-home-manager"
}

ensure_local_nix() {
  if [[ -f "$LOCAL_NIX" ]]; then
    return
  fi

  cat >&2 <<EOF
error: missing local Nix settings: $LOCAL_NIX

Create it from:
  cp "$LOCAL_NIX_EXAMPLE" "$LOCAL_NIX"

Then edit username and homeDirectory for this Mac.
EOF
  exit 1
}

run_home_manager() {
  local flake_ref="$FLAKE_DIR#default"

  if command -v home-manager >/dev/null 2>&1; then
    run_cmd home-manager switch --flake "$flake_ref"
    return
  fi

  run_cmd nix \
    --extra-experimental-features "nix-command flakes" \
    run home-manager/master -- switch --flake "$flake_ref"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -n | --dry-run)
    DRY_RUN=true
    shift
    ;;
  -y | --yes)
    AUTO_YES=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
done

APPLY_SCRIPT="$DOTFILES_DIR/scripts/apply.sh"

if [[ ! -f "$APPLY_SCRIPT" ]]; then
  echo "error: missing script: $APPLY_SCRIPT" >&2
  exit 1
fi

if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
  echo "error: missing flake: $FLAKE_DIR/flake.nix" >&2
  exit 1
fi

ensure_macos
ensure_nix
ensure_local_nix

if ! "$AUTO_YES" && ! "$DRY_RUN"; then
  read -r -p "Run bootstrap (home-manager default + apply all)? [y/N]: " ans
  case "$ans" in
  y | Y | yes | YES)
    ;;
  *)
    echo "Aborted."
    exit 0
    ;;
  esac
fi

apply_cmd=(bash "$APPLY_SCRIPT" -y all)
if "$DRY_RUN"; then
  apply_cmd+=(-n)
fi

echo "info: start home-manager (default)"
prepare_home_manager_paths
run_home_manager

echo "info: start apply"
"${apply_cmd[@]}"

echo "info: done"
echo "info: reload your shell with: exec \$SHELL -l"
