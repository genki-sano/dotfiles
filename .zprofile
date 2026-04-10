# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# mise
if [[ -x "$HOME/.nix-profile/bin/mise" ]]; then
  eval "$("$HOME/.nix-profile/bin/mise" activate zsh)"
elif command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
