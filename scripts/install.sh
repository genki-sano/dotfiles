#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
AUTO_YES=false
TARGETS=()
VALID_TARGETS=(core shell editor wezterm claude)

usage() {
  cat <<'EOF'
Usage: install.sh [-n|--dry-run] [-y|--yes] [all|core|shell|editor|wezterm|claude]...
  -n, --dry-run  Show what would change without modifying files
  -y, --yes      Skip confirmation prompt
  -h, --help     Show this help

Targets:
  all      Apply all setup categories
  core     Homebrew baseline
  shell    zsh related tools and oh-my-zsh stack
  editor   neovim + editor tools
  wezterm  wezterm + nerd font
  claude   Claude Code helper tools
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

  if "$DRY_RUN"; then
    log_info "Homebrew is not installed. It would be installed in non-dry-run mode."
    return
  fi

  log_info "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "error: brew command is not available after installation" >&2
    exit 1
  fi
}

apply_brewfile() {
  local category="$1"
  local brewfile="$DOTFILES_DIR/brew/Brewfile.$category"

  if [[ ! -f "$brewfile" ]]; then
    echo "error: missing brewfile: $brewfile" >&2
    exit 1
  fi

  if ! command -v brew >/dev/null 2>&1; then
    if "$DRY_RUN"; then
      log_skip "brew is unavailable, skip Brewfile.$category in dry-run"
      return
    fi
    echo "error: brew command is unavailable" >&2
    exit 1
  fi

  log_info "Applying Brewfile.$category"
  run_cmd brew bundle --file "$brewfile" --no-lock
}

clone_if_missing() {
  local repo="$1"
  local dest="$2"

  if [[ -d "$dest" ]]; then
    log_skip "$dest (already exists)"
    return
  fi

  run_cmd mkdir -p "$(dirname "$dest")"
  run_cmd git clone --depth 1 "$repo" "$dest"
}

apply_core() {
  apply_brewfile "core"
}

apply_shell() {
  apply_brewfile "shell"
  clone_if_missing "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"
  clone_if_missing \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  clone_if_missing \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  clone_if_missing \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
}

apply_editor() {
  apply_brewfile "editor"
}

apply_wezterm() {
  apply_brewfile "wezterm"
}

apply_claude() {
  apply_brewfile "claude"
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
  all | core | shell | editor | wezterm | claude)
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
  core)
    apply_core
    ;;
  shell)
    apply_shell
    ;;
  editor)
    apply_editor
    ;;
  wezterm)
    apply_wezterm
    ;;
  claude)
    apply_claude
    ;;
  *)
    echo "error: unknown target: $target" >&2
    exit 1
    ;;
  esac
done
