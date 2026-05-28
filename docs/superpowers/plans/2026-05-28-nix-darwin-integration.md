# nix-darwin Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `nix-darwin` を導入し、`darwin-rebuild switch` 1コマンドで macOS システム設定・パッケージ・dotfiles を宣言的に管理できるようにする。

**Architecture:** 既存の home-manager スタンドアロン構成を `nix-darwin` 統合構成に移行する。`flake.nix` の出力を `homeConfigurations` から `darwinConfigurations` に変え、home-manager を nix-darwin モジュールとして組み込む。macOS システム設定は `darwin/system.nix` に集約し、`system.defaults`・`CustomUserPreferences`・`activationScripts` の3つの仕組みで表現する。

**Tech Stack:** Nix flakes, nix-darwin, home-manager

---

## ファイルマップ

| ファイル | 操作 | 役割 |
|---|---|---|
| `.config/nix/flake.nix` | 変更 | nix-darwin input 追加、darwinConfigurations に一本化 |
| `.config/nix/darwin/default.nix` | 新規作成 | nix-darwin エントリポイント（ユーザー定義・nix設定） |
| `.config/nix/darwin/system.nix` | 新規作成 | system.defaults（defaults write コマンドの移植） |
| `.config/nix/local.nix.example` | 変更 | hostname フィールドのコメント追加 |
| `scripts/bootstrap.sh` | 変更 | run_home_manager → run_darwin に置き換え |

---

## Task 1: flake.nix の更新 + darwin/default.nix の作成（骨格）

**Files:**
- Modify: `.config/nix/flake.nix`
- Create: `.config/nix/darwin/default.nix`

- [ ] **Step 1: darwin/ ディレクトリを作成する**

```bash
mkdir -p /Users/genki.sano/dotfiles/.config/nix/darwin
```

- [ ] **Step 2: darwin/default.nix を作成する**

`.config/nix/darwin/default.nix` を以下の内容で作成する:

```nix
{ localConfig, ... }:
{
  imports = [ ./system.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${localConfig.username} = {
    name = localConfig.username;
    home = localConfig.homeDirectory;
  };

  system.stateVersion = 6;
}
```

- [ ] **Step 3: flake.nix を書き換える**

`.config/nix/flake.nix` を以下の内容に置き換える（`homeConfigurations` を廃止し `darwinConfigurations` に一本化する）:

```nix
{
  description = "dotfiles managed with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nix-darwin, home-manager, ... }:
    let
      homeDir = builtins.getEnv "HOME";
      localConfigPath = "${homeDir}/.config/dotfiles/local.nix";
      localConfig =
        if homeDir == "" then
          throw ''
            HOME is not available during flake evaluation.

            Run with --impure so ~/.config/dotfiles/local.nix can be read.
          ''
        else if !builtins.pathExists localConfigPath then
          throw ''
            Missing local Nix settings: ${localConfigPath}

            Create it from:
              mkdir -p ~/.config/dotfiles
              cp ./.config/nix/local.nix.example ~/.config/dotfiles/local.nix
          ''
        else
          import localConfigPath;
    in {
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit localConfig; };
        modules = [
          ./darwin/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${localConfig.username} = import ./home/common.nix;
          }
        ];
      };
    };
}
```

- [ ] **Step 4: flake の出力構造を確認する**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix flake show --impure --extra-experimental-features "nix-command flakes"
```

期待する出力（`darwinConfigurations` が表示されること）:

```
git+file:///...
└── darwinConfigurations
    └── default: Darwin configuration
```

- [ ] **Step 5: ビルドが通ることを確認する（適用なし）**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --impure --extra-experimental-features "nix-command flakes" \
  .#darwinConfigurations.default.system
```

期待: `result` シンボリックリンクが作成される（エラーなし）

- [ ] **Step 6: コミットする**

```bash
git add .config/nix/flake.nix .config/nix/darwin/default.nix
git commit -m "feat(nix): migrate to nix-darwin, integrate home-manager as module"
```

---

## Task 2: darwin/system.nix の作成（macOS システム設定移植）

**Files:**
- Create: `.config/nix/darwin/system.nix`

- [ ] **Step 1: darwin/system.nix を作成する**

`.config/nix/darwin/system.nix` を以下の内容で作成する:

```nix
{ ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      AppleShowScrollBars = "Always";
      NSWindowResizeTime = 1.0e-3;
    };
    finder = {
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf";
    };

    CustomUserPreferences = {
      "com.apple.CrashReporter".DialogType = "none";
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.Safari" = {
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;
        ShowFullURLInSmartSearchField = true;
        AutoOpenSafeDownloads = false;
        IncludeInternalDebugMenu = true;
        "ProxiesInBookmarksBar" = "()";
        WebAutomaticSpellingCorrectionEnabled = false;
        AutoFillFromAddressBook = false;
        AutoFillPasswords = false;
        AutoFillCreditCardData = false;
        AutoFillMiscellaneousForms = false;
        WebKitPluginsEnabled = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled" = false;
        WebKitJavaEnabled = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
        WebKitJavaScriptCanOpenWindowsAutomatically = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
        SendDoNotTrackHTTPHeader = true;
      };
    };
  };

  system.activationScripts.postUserActivation.text = ''
    chflags nohidden ~/Library
  '';
  system.activationScripts.postActivation.text = ''
    chflags nohidden /Volumes
    systemsetup -setrestartfreeze on 2>/dev/null || true
  '';
}
```

- [ ] **Step 2: ビルドが通ることを確認する**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --impure --extra-experimental-features "nix-command flakes" \
  .#darwinConfigurations.default.system
```

期待: エラーなし（`result` シンボリックリンクが更新される）

- [ ] **Step 3: コミットする**

```bash
git add .config/nix/darwin/system.nix
git commit -m "feat(nix): add macOS system defaults via nix-darwin"
```

---

## Task 3: local.nix.example の更新

**Files:**
- Modify: `.config/nix/local.nix.example`

- [ ] **Step 1: local.nix.example に hostname フィールドのコメントを追加する**

`.config/nix/local.nix.example` を以下の内容に書き換える:

```nix
{
  username = "your-user";
  homeDirectory = "/Users/your-user";
  # hostname = "your-hostname";  # optional: sets networking.hostName
}
```

- [ ] **Step 2: コミットする**

```bash
git add .config/nix/local.nix.example
git commit -m "docs(nix): add hostname field comment to local.nix.example"
```

---

## Task 4: bootstrap.sh の更新

**Files:**
- Modify: `scripts/bootstrap.sh`

- [ ] **Step 1: run_home_manager 関数を run_darwin に置き換える**

`scripts/bootstrap.sh` の 91〜102 行目の `run_home_manager` 関数を以下に置き換える:

```bash
run_darwin() {
  local flake_ref="$FLAKE_DIR#default"

  if command -v darwin-rebuild >/dev/null 2>&1; then
    run_cmd darwin-rebuild switch --impure --flake "$flake_ref"
    return
  fi

  run_cmd nix \
    --extra-experimental-features "nix-command flakes" \
    run nix-darwin -- switch --impure --flake "$flake_ref"
}
```

- [ ] **Step 2: プロンプト文言と呼び出し箇所を更新する**

同ファイルの以下の箇所を変更する:

146行目:
```bash
# 変更前
  prompt="Run bootstrap (home-manager default + apply all)? [y/N]: "
# 変更後
  prompt="Run bootstrap (nix-darwin default + apply all)? [y/N]: "
```

148行目:
```bash
# 変更前
    prompt="Run bootstrap (home-manager default only)? [y/N]: "
# 変更後
    prompt="Run bootstrap (nix-darwin default only)? [y/N]: "
```

162行目:
```bash
# 変更前
echo "info: start home-manager (default)"
# 変更後
echo "info: start nix-darwin (default)"
```

164行目:
```bash
# 変更前
run_home_manager
# 変更後
run_darwin
```

- [ ] **Step 3: dry-run で動作確認する**

```bash
bash /Users/genki.sano/dotfiles/scripts/bootstrap.sh --dry-run --yes --no-apply
```

期待する出力（`run_darwin` の動きが dry-run で表示されること）:

```
info: start nix-darwin (default)
dry-run: darwin-rebuild switch --impure --flake /Users/genki.sano/dotfiles/.config/nix#default
info: skip apply (--no-apply)
info: done
info: reload your shell with: exec $SHELL -l
```

または darwin-rebuild が未インストールの場合は `nix run nix-darwin ...` の行が出力される。

- [ ] **Step 4: コミットする**

```bash
git add scripts/bootstrap.sh
git commit -m "feat(bootstrap): switch from home-manager to darwin-rebuild"
```

---

## Task 5: 最終ビルド確認・適用

**Files:** なし（確認のみ）

- [ ] **Step 1: 最終ビルドを確認する（適用なし）**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --impure --extra-experimental-features "nix-command flakes" \
  .#darwinConfigurations.default.system
```

期待: エラーなし

- [ ] **Step 2: nix-darwin を初回適用する**

`darwin-rebuild` がまだインストールされていない場合:

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin -- switch --impure --flake .#default
```

`darwin-rebuild` がすでにある場合:

```bash
darwin-rebuild switch --impure --flake /Users/genki.sano/dotfiles/.config/nix#default
```

- [ ] **Step 3: 設定が反映されていることを確認する**

```bash
# スクロールバー設定の確認
defaults read NSGlobalDomain AppleShowScrollBars
# 期待: "Always"

# Finder パスバー設定の確認
defaults read com.apple.finder ShowPathbar
# 期待: 1

# Safari 設定の確認
defaults read com.apple.Safari UniversalSearchEnabled
# 期待: 0
```

- [ ] **Step 4: シェルを再起動する**

```bash
exec $SHELL -l
```
