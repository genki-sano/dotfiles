# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# 各種設定を読み込む
# ohmy.zsh: Oh My Zsh 関連
# options.zsh: その他のカスタム設定
SCRIPT_DIR=${${(%):-%x}:A:h}
for f in ohmy options; do
 [[ -r "$SCRIPT_DIR/config/$f.zsh" ]] && source "$SCRIPT_DIR/config/$f.zsh"
done
