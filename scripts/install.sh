#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
AUTO_YES=false
TARGETS=()
VALID_TARGETS=(wezterm)

usage() {
  cat <<'EOF'
Usage: install.sh [-n|--dry-run] [-y|--yes] [all|wezterm]...
  -n, --dry-run  Show what would change without modifying files
  -y, --yes      Skip confirmation prompt
  -h, --help     Show this help

Targets:
  all      Install all optional Homebrew-managed packages
  wezterm  wezterm

Core CLI, shell, editor, and Claude helper tools are now managed by Nix/Home Manager.
Use ./scripts/bootstrap.sh for the main setup flow.
EOF
}

log_info() {
  echo "info: $*"
}

log_skip() {
  echo "skip: $*"
}

run_cmd() {
  if "$DRY_RUN"; then
    echo "dry-run: $*"
  else
    "$@"
  fi
}

contains_target() {
  local target="$1"
  shift
  for item in "$@"; do
    if [[ "$item" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

ensure_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "error: install.sh is supported only on macOS" >&2
    exit 1
  fi
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  if command -v brew >/dev/null 2>&1; then
    return
  fi

  cat >&2 <<'EOF'
error: brew command is not installed.

Install Homebrew from the official website:
  https://brew.sh/
EOF
  exit 1
}

apply_wezterm() {
  if ! command -v brew >/dev/null 2>&1; then
    if "$DRY_RUN"; then
      log_skip "brew is unavailable, skip wezterm install in dry-run"
      return
    fi
    echo "error: brew command is unavailable" >&2
    exit 1
  fi

  log_info "Installing wezterm"
  run_cmd brew install --cask wezterm
}

prompt_targets() {
  local selected=()
  local options=("${VALID_TARGETS[@]}" "all" "done")

  echo "Select setup targets (choose repeatedly, then select 'done'):"
  select opt in "${options[@]}"; do
    if [[ -z "${opt:-}" ]]; then
      echo "Invalid selection"
      continue
    fi

    if [[ "$opt" == "done" ]]; then
      break
    fi

    if [[ "$opt" == "all" ]]; then
      TARGETS=("all")
      return
    fi

    if contains_target "$opt" "${selected[@]}"; then
      log_skip "$opt (already selected)"
      continue
    fi

    selected+=("$opt")
    log_info "selected: ${selected[*]}"
  done

  if [[ ${#selected[@]} -eq 0 ]]; then
    TARGETS=("all")
  else
    TARGETS=("${selected[@]}")
  fi
}

confirm_execution() {
  if "$AUTO_YES" || "$DRY_RUN"; then
    return
  fi

  echo "Targets: ${TARGETS[*]}"
  read -r -p "Proceed? [y/N]: " ans
  case "$ans" in
  y | Y | yes | YES)
    ;;
  *)
    echo "Aborted."
    exit 0
    ;;
  esac
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
  all | wezterm)
    TARGETS+=("$1")
    shift
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  prompt_targets
fi

if contains_target "all" "${TARGETS[@]}" && [[ ${#TARGETS[@]} -gt 1 ]]; then
  echo "error: 'all' cannot be combined with other targets" >&2
  exit 1
fi

if contains_target "all" "${TARGETS[@]}"; then
  TARGETS=("${VALID_TARGETS[@]}")
fi

ensure_macos
ensure_homebrew
confirm_execution

for target in "${TARGETS[@]}"; do
  case "$target" in
  wezterm)
    apply_wezterm
    ;;
  *)
    echo "error: unknown target: $target" >&2
    exit 1
    ;;
  esac
done
