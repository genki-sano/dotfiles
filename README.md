# dotfiles

個人開発環境を **コードで再現** するための設定ファイル集です。

![Alt](https://repobeats.axiom.co/api/embed/493ae1a741d3a82e213e20b39b69800aefaab3f5.svg "Repobeats analytics image")

## Supported OS

- macOS (recommend)

## Setup

### 1. リポジトリを取得する

```bash
git clone https://github.com/genki-sano/dotfiles.git
cd dotfiles
```

### 2. セットアップを実行する

`bootstrap.sh` は `install.sh` と `apply.sh` を順に実行します。

```bash
chmod +x ./scripts/bootstrap.sh
./scripts/bootstrap.sh
```

### 3. シェルを再読み込みする

```bash
exec $SHELL -l
```

### 4. 任意: Node を有効化する（mise）

```bash
mise use --global node@lts
```

## Components

- zsh
- neovim
- wezterm

## License

This project is licensed under the MIT License, see [LICENSE](LICENSE).
