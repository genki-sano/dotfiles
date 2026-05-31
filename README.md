# dotfiles

macOS 向けの個人開発環境です。

![Alt](https://repobeats.axiom.co/api/embed/493ae1a741d3a82e213e20b39b69800aefaab3f5.svg "Repobeats analytics image")

## Overview

この repo は、macOS 上のシェル、エディタ、ターミナル周辺設定を再現するための dotfiles です。

- メインのセットアップ入口は `sudo nix run ... nix-darwin -- switch --flake ...`
- CLI 環境・macOS システム設定の適用は nix-darwin + Home Manager
- shell/editor/terminal 周辺の dotfiles symlink 反映は Home Manager
- optional な追加インストールは `scripts/install.sh`

## What This Repo Manages

### nix-darwin + Home Manager

`.config/nix/` 配下の設定から、CLI・shell・editor の主な環境と macOS システム設定を適用します。

- `darwin/system.nix`: macOS システム設定（Dock、Finder、Safari など `defaults write` 相当）
- `home-manager/default.nix`: Home Manager 設定の入口
- `home-manager/common.nix`: CLI パッケージと Home Manager 共通設定
- `home-manager/dotfiles.nix`: dotfiles symlink 管理
- `hosts/default.nix`: このマシン固有の設定（username、system、dotfilesDirectory）

### Symlinked Dotfiles

Home Manager で次の設定をホームディレクトリへ反映します。

- `zsh`
- `vim`
- `nvim`
- `wezterm`
- `ghostty`

`git` と `claude` は Home Manager 管理の対象外です。必要な場合は `scripts/apply.sh` で手動反映できます。

### Homebrew

Homebrew管理は任意です。現状の対象は `wezterm` です。

## Supported OS

- macOS (Apple Silicon / arm64)

## Setup

### 0. Prerequisites

- [Nix](https://nixos.org/download/)
- [Homebrew](https://brew.sh/)（optional package を入れる場合のみ）

### 1. Clone

```bash
git clone https://github.com/genki-sano/dotfiles.git ~/dotfiles && cd ~/dotfiles
```

※ `git` が未導入なら:

```bash
nix shell nixpkgs#git -c git clone https://github.com/genki-sano/dotfiles.git ~/dotfiles && cd ~/dotfiles
```

### 2. Edit host config

`.config/nix/hosts/default.nix` の `username` と `system` をこの Mac 用に編集します。
dotfiles を `~/dotfiles` 以外に置く場合は `dotfilesDirectory` も指定します。

```nix
{
  hostSpec = {
    username = "your-user";
    system = "aarch64-darwin";
    dotfilesDirectory = "/Users/your-user/dotfiles";
  };
}
```

### 3. Apply nix-darwin

```bash
sudo nix run \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  nix-darwin -- switch --flake "$HOME/dotfiles/.config/nix#default"
```

このコマンドは次を適用します。

- nix-darwin の `default` 設定
- Home Manager の CLI パッケージと dotfiles symlink
- 初回に競合しやすい `/etc/nix/nix.conf`・`/etc/bashrc`・`/etc/zshrc` の自動退避

退避先は `<path>.before-nix-darwin` です。既に退避先がある場合は上書きしません。

### 4. Reload shell

```bash
exec $SHELL -l
```

## Daily Usage

nix-darwin の設定を更新する:

```bash
nix run ~/dotfiles/.config/nix#switch
```

`git` / `claude` など Home Manager 管理外の symlink を手動で貼り直す:

```bash
./scripts/apply.sh git claude
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

- `scripts/`: 手動 symlink 適用、optional インストール、互換用 bootstrap の入口
- `.config/nix/`: nix-darwin + Home Manager 設定
  - `darwin/`: nix-darwin システム設定（macOS defaults、activation scripts）
  - `home-manager/`: Home Manager 設定
  - `hosts/`: マシン固有設定（username、system、dotfilesDirectory）
  - `modules/`: 共通 Nix モジュール定義
- `.zshrc`, `.zprofile`, `.config/*`, `.claude/*`: 設定ファイル

## Notes

- マシン固有の設定（username、system、dotfilesDirectory）は `.config/nix/hosts/default.nix` に直書きします。複数マシンで使う場合は `hosts/` 以下にホスト名ごとのファイルを追加し、`flake.nix` に対応する `darwinConfigurations` エントリを追加してください。
- nix-darwin の構成は現時点で `aarch64-darwin` を前提にしています。
- `scripts/apply.sh` は Home Manager 管理外の symlink を手動反映したい場合に使います。既存ファイルがある場合、バックアップを取ってから symlink を貼ります。

## License

This project is licensed under the MIT License, see [LICENSE](LICENSE).
