# dotfiles

macOS 向けの個人開発環境です。

![Alt](https://repobeats.axiom.co/api/embed/493ae1a741d3a82e213e20b39b69800aefaab3f5.svg "Repobeats analytics image")

## Overview

この repo は、macOS 上のシェル、エディタ、ターミナル周辺設定を再現するための dotfiles です。

- メインのセットアップ入口は `scripts/bootstrap.sh`
- CLI 環境の適用は Home Manager
- dotfiles の symlink 反映は `scripts/apply.sh`
- optional な追加インストールは `scripts/install.sh`

## What This Repo Manages

### Home Manager

`.config/nix/` 配下の設定から、CLI・shell・editor の主な環境を適用します。

### Symlinked Dotfiles

`scripts/apply.sh` で次の設定をホームディレクトリへ反映します。

- `zsh`
- `vim`
- `nvim`
- `wezterm`
- `git`
- `claude`

### Homebrew

Homebrew管理は任意です。現状の対象は `wezterm` です。

## Supported OS

- macOS (Apple Silicon / arm64)

## Setup

### 0. Prerequisites

- [Nix](https://nixos.org/download/)
- [Homebrew](https://brew.sh/)

### 1. Clone

```bash
git clone https://github.com/genki-sano/dotfiles.git ~/dotfiles && cd ~/dotfiles
```

※ `git` が未導入なら:

```bash
nix shell nixpkgs#git -c git clone https://github.com/genki-sano/dotfiles.git ~/dotfiles && cd ~/dotfiles
```

### 2. Create local config

```bash
mkdir -p ~/.config/dotfiles
cp ./.config/nix/local.nix.example ~/.config/dotfiles/local.nix
```

その後、[`.config/nix/local.nix.example`](.config/nix/local.nix.example) を参考に、`~/.config/dotfiles/local.nix` にこの Mac 用の `username` と `homeDirectory` を設定します。

### 3. Run bootstrap

```bash
chmod +x ./scripts/bootstrap.sh && ./scripts/bootstrap.sh
```

`bootstrap.sh` は次を順に実行します。

- Home Manager の `default` profile を適用
- 既存の `.oh-my-zsh` 関連を必要なら退避
- `scripts/apply.sh -y all` で dotfiles の symlink を反映

### 4. Reload shell

```bash
exec $SHELL -l
```

## Daily Usage

Home Manager の設定を更新する:

```bash
home-manager switch --impure --flake ./.config/nix#default
```

symlink だけ貼り直す:

```bash
./scripts/apply.sh all
```

特定の optional package を入れる:

```bash
./scripts/install.sh wezterm
```

## Optional Components

Node を有効化する（mise）:

```bash
mise use --global node@lts
```

WezTerm を Homebrew で入れる:

```bash
./scripts/install.sh wezterm
```

## Repository Layout

- `scripts/`: セットアップ、symlink 適用、optional インストールの入口
- `.config/nix/`: Home Manager とローカル設定
- `.zshrc`, `.zprofile`, `.config/*`, `.claude/*`: 反映対象の設定ファイル

## Notes

- `local.nix` を分けているのは、実ユーザー名とホームディレクトリを公開 repo に含めないためです。配置先は repo 外の `~/.config/dotfiles/local.nix` です。
- Nix / Home Manager の構成は現時点で `aarch64-darwin` を前提にしています。
- `~/.config/dotfiles/local.nix` を読むため、Home Manager の flake 実行は `--impure` 前提です。
- `scripts/apply.sh` は既存ファイルがある場合、バックアップを取ってから symlink を貼ります。

## License

This project is licensed under the MIT License, see [LICENSE](LICENSE).
