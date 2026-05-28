#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLAKE_DIR="$DOTFILES_DIR/.config/nix"
DRY_RUN=false
AUTO_YES=false
SKIP_APPLY=false

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [-n|--dry-run] [-y|--yes] [--no-apply]
  -n, --dry-run  Show what would change without modifying files
  -y, --yes      Skip confirmation prompt
  --no-apply     Skip running scripts/apply.sh
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

run_darwin() {
  local flake_ref="$FLAKE_DIR#default"

  if command -v darwin-rebuild >/dev/null 2>&1; then
    run_cmd sudo darwin-rebuild switch --flake "$flake_ref"
    return
  fi

  # First-time bootstrap: darwin-rebuild is not yet installed
  run_cmd nix build \
    --extra-experimental-features "nix-command flakes" \
    --out-link /tmp/nix-darwin-result \
    "$FLAKE_DIR#darwinConfigurations.default.system"
  run_cmd sudo /tmp/nix-darwin-result/activate
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
  --no-apply)
    SKIP_APPLY=true
    shift
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

if ! "$AUTO_YES" && ! "$DRY_RUN"; then
  prompt="Run bootstrap (nix-darwin default + apply all)? [y/N]: "
  if "$SKIP_APPLY"; then
    prompt="Run bootstrap (nix-darwin default only)? [y/N]: "
  fi

  read -r -p "$prompt" ans
  case "$ans" in
  y | Y | yes | YES)
    ;;
  *)
    echo "Aborted."
    exit 0
    ;;
  esac
fi

echo "info: start nix-darwin (default)"
prepare_home_manager_paths
run_darwin

if "$SKIP_APPLY"; then
  echo "info: skip apply (--no-apply)"
else
  apply_cmd=(bash "$APPLY_SCRIPT" -y all)
  if "$DRY_RUN"; then
    apply_cmd+=(-n)
  fi

  echo "info: start apply"
  "${apply_cmd[@]}"
fi

echo "info: done"
echo "info: reload your shell with: exec \$SHELL -l"
