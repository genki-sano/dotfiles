# 日本語を使用
export LANG=ja_JP.UTF-8

# コマンドのスペルミスを指摘
setopt correct

# ヒストリー関連
setopt extended_history   # 履歴ファイルにzsh の開始・終了時刻を記録する
setopt hist_ignore_dups   # 重複するコマンドが保存されるとき、古い方を削除する
setopt hist_reduce_blanks # 余分な空白は詰めて記録


# alias ----------------------------------------------

## ls
alias ls='ls -G'
alias la='ls -a'
alias ll='ls -alF'

## zsh
alias vz='vim ~/.zshrc'
ZSH_DIR=${0:A:h}
alias vzo="vim $ZSH_DIR/ohmy.zsh"
alias vzp="vim $ZSH_DIR/p10k.zsh"
alias vze="vim $ZSH_DIR/options.zsh"

## others
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias re='exec $SHELL -l'

