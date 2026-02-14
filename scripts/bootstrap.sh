#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
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

INSTALL_SCRIPT="$DOTFILES_DIR/scripts/install.sh"
APPLY_SCRIPT="$DOTFILES_DIR/scripts/apply.sh"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  echo "error: missing script: $INSTALL_SCRIPT" >&2
  exit 1
fi

if [[ ! -f "$APPLY_SCRIPT" ]]; then
  echo "error: missing script: $APPLY_SCRIPT" >&2
  exit 1
fi

if ! "$AUTO_YES" && ! "$DRY_RUN"; then
  read -r -p "Run full bootstrap (install all + apply all)? [y/N]: " ans
  case "$ans" in
  y | Y | yes | YES)
    ;;
  *)
    echo "Aborted."
    exit 0
    ;;
  esac
fi

install_cmd=(bash "$INSTALL_SCRIPT" -y all)
apply_cmd=(bash "$APPLY_SCRIPT" all)

if "$DRY_RUN"; then
  install_cmd+=(-n)
  apply_cmd+=(-n)
fi

echo "info: start install"
"${install_cmd[@]}"

echo "info: start apply"
"${apply_cmd[@]}"

echo "info: done"
