#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles.bk.$(date "+%Y%m%d")"
DRY_RUN=false
AUTO_YES=false
TARGETS=()
VALID_TARGETS=(zsh vim wezterm git claude)

usage() {
  cat <<'EOF'
Usage: apply.sh [-n|--dry-run] [-y|--yes] [all|zsh|vim|wezterm|git|claude]...
  -n, --dry-run  Show what would change without modifying files
  -y, --yes      Skip confirmation prompt
  -h, --help     Show this help

Targets:
  all      Apply all symlinks (default)
  zsh      .zshrc, .zprofile, .config/zsh
  vim      .vimrc, .config/nvim
  wezterm  .config/wezterm
  git      .config/git
  claude   .claude/*
EOF
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

prompt_targets() {
  local selected=()
  local options=("${VALID_TARGETS[@]}" "all" "done")

  echo "Select apply targets (choose repeatedly, then select 'done'):"
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
      echo "skip: $opt (already selected)"
      continue
    fi

    selected+=("$opt")
    echo "info: selected: ${selected[*]}"
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
  all | zsh | vim | wezterm | git | claude)
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

if [[ " ${TARGETS[*]} " == *" all "* && ${#TARGETS[@]} -gt 1 ]]; then
  echo "error: 'all' cannot be combined with other targets" >&2
  exit 1
fi

if [[ " ${TARGETS[*]} " == *" all "* ]]; then
  TARGETS=("${VALID_TARGETS[@]}")
fi

confirm_execution

backup_and_link() {
  local src_rel="$1"
  local dest="$HOME/$src_rel"
  local backup="$BACKUP_DIR/$src_rel"
  local src="$DOTFILES_DIR/$src_rel"

  if [[ ! -e "$src" ]]; then
    echo "warn: source not found, skip: $src" >&2
    return 0
  fi

  run_cmd mkdir -p "$(dirname "$dest")"

  # すでに正しいリンクが貼られている場合はスキップ
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    echo "skip: $dest (already linked)"
    return
  fi

  # 現行のファイルがある場合は、バックアップしておく
  if [[ -e "$dest" || -L "$dest" ]]; then
    run_cmd mkdir -p "$(dirname "$backup")"
    run_cmd mv "$dest" "$backup"
    echo "backup: $dest -> $backup"
  fi

  run_cmd ln -s "$src" "$dest"
  echo "link: $dest -> $src"
}

apply_zsh() {
  backup_and_link ".zshrc"
  backup_and_link ".zprofile"
  backup_and_link ".config/zsh"
}

apply_vim() {
  backup_and_link ".vimrc"
  backup_and_link ".config/nvim"
}

apply_wezterm() {
  backup_and_link ".config/wezterm"
}

apply_git() {
  backup_and_link ".config/git"
}

apply_claude() {
  backup_and_link ".claude/statusline.sh"
  backup_and_link ".claude/settings.json"
  backup_and_link ".claude/CLAUDE.md"
  backup_and_link ".claude/skills"
}

for target in "${TARGETS[@]}"; do
  case "$target" in
  all)
    apply_zsh
    apply_vim
    apply_wezterm
    apply_git
    apply_claude
    ;;
  zsh)
    apply_zsh
    ;;
  vim)
    apply_vim
    ;;
  wezterm)
    apply_wezterm
    ;;
  git)
    apply_git
    ;;
  claude)
    apply_claude
    ;;
  esac
done
