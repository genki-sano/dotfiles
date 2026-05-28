# nix-darwin hostSpec Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `builtins.getEnv "HOME"` / `local.nix` 方式を廃止し、mozumasu/dotfiles と同様の `hostSpec` Nix モジュール方式に移行することで、`--impure` 不要・root 実行時の HOME 問題を根本解決する。

**Architecture:** ホスト固有設定（username/homeDirectory）を Nix オプション (`options.hostSpec`) として宣言し、`hosts/default.nix` に値を直書きする。flake.nix は環境変数に依存しない純粋な評価になる。`apps` セクションで `nix run .#switch` ショートカットを提供する。

**Tech Stack:** Nix flakes, nix-darwin, home-manager

---

## ファイルマップ

| ファイル | 操作 | 役割 |
|---|---|---|
| `.config/nix/modules/hostSpec.nix` | 新規作成 | `options.hostSpec` の宣言（username, homeDirectory） |
| `.config/nix/hosts/default.nix` | 新規作成 | このマシンの hostSpec 値（genki.sano） |
| `.config/nix/flake.nix` | 変更 | `builtins.getEnv "HOME"` 廃止、`apps` 追加、`hostSpec` 経由に |
| `.config/nix/darwin/default.nix` | 変更 | `localConfig` → `config.hostSpec` |
| `.config/nix/darwin/system.nix` | 変更 | `localConfig` → `config.hostSpec` |
| `.config/nix/local.nix.example` | 削除 | `hostSpec` 方式に不要 |
| `scripts/bootstrap.sh` | 変更 | `ensure_local_nix` 削除、初回 bootstrap を `nix build` + `sudo activate` に |

---

## Task 1: modules/hostSpec.nix + hosts/default.nix の作成

**Files:**
- Create: `.config/nix/modules/hostSpec.nix`
- Create: `.config/nix/hosts/default.nix`

- [ ] **Step 1: ディレクトリを作成する**

```bash
mkdir -p /Users/genki.sano/dotfiles/.config/nix/modules
mkdir -p /Users/genki.sano/dotfiles/.config/nix/hosts
```

- [ ] **Step 2: modules/hostSpec.nix を作成する**

`.config/nix/modules/hostSpec.nix` を以下の内容で作成する:

```nix
{ lib, ... }:
{
  options.hostSpec = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username for this host";
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "Home directory path for this host";
    };
  };
}
```

- [ ] **Step 3: hosts/default.nix を作成する**

`.config/nix/hosts/default.nix` を以下の内容で作成する:

```nix
{ ... }:
{
  hostSpec = {
    username = "genki.sano";
    homeDirectory = "/Users/genki.sano";
  };
}
```

- [ ] **Step 4: コミットする**

```bash
git -C /Users/genki.sano/dotfiles add .config/nix/modules/hostSpec.nix .config/nix/hosts/default.nix
git -C /Users/genki.sano/dotfiles commit -m "feat(nix): add hostSpec module and host-specific config"
```

---

## Task 2: flake.nix の書き換え

**Files:**
- Modify: `.config/nix/flake.nix`

- [ ] **Step 1: flake.nix を以下の内容に完全に書き換える**

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

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      mkApp = name: script: {
        type = "app";
        program = "${pkgs.writeShellApplication {
          inherit name;
          text = script;
        }}/bin/${name}";
      };
    in {
      apps.${system} = {
        switch = mkApp "darwin-switch" ''
          sudo darwin-rebuild switch --flake "${self}#default"
        '';
        build = mkApp "darwin-build" ''
          darwin-rebuild build --flake "${self}#default"
        '';
      };

      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./modules/hostSpec.nix
          ./hosts/default.nix
          ./darwin/default.nix
          home-manager.darwinModules.home-manager
          ({ config, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${config.hostSpec.username} = import ./home/common.nix;
          })
        ];
      };
    };
}
```

- [ ] **Step 2: flake の出力構造を確認する（--impure 不要）**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix flake show --extra-experimental-features "nix-command flakes"
```

期待する出力（`--impure` なしで評価できること）:

```
git+file:///...
├── apps
│   └── aarch64-darwin
│       ├── build: app
│       └── switch: app
└── darwinConfigurations
    └── default: Darwin configuration
```

- [ ] **Step 3: コミットする**

```bash
git -C /Users/genki.sano/dotfiles add .config/nix/flake.nix
git -C /Users/genki.sano/dotfiles commit -m "feat(nix): replace local.nix/HOME approach with hostSpec modules"
```

---

## Task 3: darwin/default.nix + darwin/system.nix の更新

**Files:**
- Modify: `.config/nix/darwin/default.nix`
- Modify: `.config/nix/darwin/system.nix`

- [ ] **Step 1: darwin/default.nix を書き換える**

`.config/nix/darwin/default.nix` を以下の内容に置き換える:

```nix
{ config, ... }:
{
  imports = [ ./system.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${config.hostSpec.username} = {
    name = config.hostSpec.username;
    home = config.hostSpec.homeDirectory;
  };

  system.stateVersion = 6;
}
```

- [ ] **Step 2: darwin/system.nix を書き換える**

`.config/nix/darwin/system.nix` を以下の内容に置き換える:

```nix
{ config, ... }:
{
  system.primaryUser = config.hostSpec.username;

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

  system.activationScripts.postActivation.text = ''
    chflags nohidden /Users/${config.hostSpec.username}/Library
    chflags nohidden /Volumes
    systemsetup -setrestartfreeze on 2>/dev/null || true
  '';
}
```

- [ ] **Step 3: ビルドが通ることを確認する（--impure 不要）**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --extra-experimental-features "nix-command flakes" \
  .#darwinConfigurations.default.system
```

期待: エラーなし、`result` シンボリックリンクが作成される

- [ ] **Step 4: コミットする**

```bash
git -C /Users/genki.sano/dotfiles add .config/nix/darwin/default.nix .config/nix/darwin/system.nix
git -C /Users/genki.sano/dotfiles commit -m "feat(nix): migrate darwin modules from localConfig to config.hostSpec"
```

---

## Task 4: bootstrap.sh の更新

**Files:**
- Modify: `scripts/bootstrap.sh`

- [ ] **Step 1: LOCAL_NIX / LOCAL_NIX_EXAMPLE 変数を削除する**

`scripts/bootstrap.sh` の先頭変数宣言から以下の2行を削除する:

```bash
LOCAL_NIX="$HOME/.config/dotfiles/local.nix"
LOCAL_NIX_EXAMPLE="$FLAKE_DIR/local.nix.example"
```

- [ ] **Step 2: ensure_local_nix 関数を削除する**

以下のブロックを丸ごと削除する:

```bash
ensure_local_nix() {
  if [[ -f "$LOCAL_NIX" ]]; then
    return
  fi

  cat >&2 <<EOF
error: missing local Nix settings: $LOCAL_NIX

Create it from:
  mkdir -p "$(dirname "$LOCAL_NIX")"
  cp "$LOCAL_NIX_EXAMPLE" "$LOCAL_NIX"

Then edit username and homeDirectory for this Mac.
EOF
  exit 1
}
```

- [ ] **Step 3: ensure_local_nix の呼び出しを削除する**

メイン処理の中の以下の行を削除する:

```bash
ensure_local_nix
```

- [ ] **Step 4: run_darwin 関数を書き換える**

現在の `run_darwin` 関数:

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

を以下に置き換える:

```bash
run_darwin() {
  local flake_ref="$FLAKE_DIR#default"

  if command -v darwin-rebuild >/dev/null 2>&1; then
    run_cmd sudo darwin-rebuild switch --flake "$flake_ref"
    return
  fi

  # First-time bootstrap: darwin-rebuild is not yet installed
  run_cmd nix build \
    --extra-experimental-features "nix-command flakes" \
    --out-link /tmp/nix-darwin-result \
    "$FLAKE_DIR#darwinConfigurations.default.system"
  run_cmd sudo /tmp/nix-darwin-result/activate
}
```

- [ ] **Step 5: dry-run で動作確認する**

```bash
bash /Users/genki.sano/dotfiles/scripts/bootstrap.sh --dry-run --yes --no-apply
```

期待する出力（`darwin-rebuild` 未インストールの場合）:

```
info: start nix-darwin (default)
dry-run: nix build --extra-experimental-features nix-command flakes --out-link /tmp/nix-darwin-result /Users/genki.sano/dotfiles/.config/nix#darwinConfigurations.default.system
dry-run: sudo /tmp/nix-darwin-result/activate
info: skip apply (--no-apply)
info: done
info: reload your shell with: exec $SHELL -l
```

- [ ] **Step 6: コミットする**

```bash
git -C /Users/genki.sano/dotfiles add scripts/bootstrap.sh
git -C /Users/genki.sano/dotfiles commit -m "feat(bootstrap): remove local.nix dependency, use nix build + activate for first-time setup"
```

---

## Task 5: local.nix.example の削除

**Files:**
- Delete: `.config/nix/local.nix.example`

- [ ] **Step 1: local.nix.example を削除する**

```bash
git -C /Users/genki.sano/dotfiles rm .config/nix/local.nix.example
git -C /Users/genki.sano/dotfiles commit -m "chore(nix): remove local.nix.example (replaced by hosts/default.nix)"
```

---

## Task 6: 最終ビルド確認・適用

**Files:** なし（確認のみ）

- [ ] **Step 1: クリーンビルドを確認する**

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --extra-experimental-features "nix-command flakes" \
  .#darwinConfigurations.default.system
```

期待: エラーなし（`--impure` 不要）

- [ ] **Step 2: nix-darwin を初回適用する**

`darwin-rebuild` がまだインストールされていないため:

```bash
sudo /Users/genki.sano/dotfiles/.config/nix/result/activate
```

または改めてビルドしてから:

```bash
cd /Users/genki.sano/dotfiles/.config/nix
nix build --extra-experimental-features "nix-command flakes" .#darwinConfigurations.default.system
sudo ./result/activate
```

- [ ] **Step 3: 設定が反映されていることを確認する**

```bash
defaults read NSGlobalDomain AppleShowScrollBars
# 期待: "Always"

defaults read com.apple.finder ShowPathbar
# 期待: 1

defaults read com.apple.Safari UniversalSearchEnabled
# 期待: 0
```

- [ ] **Step 4: 2回目以降の更新方法を確認する**

`darwin-rebuild` がインストールされた後:

```bash
# 直接
sudo darwin-rebuild switch --flake ~/dotfiles/.config/nix#default

# または flake app 経由
nix run ~/dotfiles/.config/nix#switch
```
