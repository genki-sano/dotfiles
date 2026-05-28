# nix-darwin 統合設計

## 概要

現在 home-manager スタンドアロンで管理している Nix 環境に `nix-darwin` を導入し、macOS システム設定（`defaults write` 相当）も含めて宣言的に管理できるようにする。

- home-manager は nix-darwin モジュールとして統合
- `darwin-rebuild switch` 1コマンドで全設定を適用
- Homebrew は引き続き手動管理

## ファイル構成

### 新規追加

```
.config/nix/
└── darwin/
    ├── default.nix    # nix-darwin エントリポイント
    └── system.nix     # system.defaults（macOS システム設定）
```

### 変更

| ファイル | 変更内容 |
|---|---|
| `flake.nix` | `darwinConfigurations` に一本化、`nix-darwin` input 追加 |
| `local.nix.example` | `hostname` フィールドを任意追加 |
| `scripts/bootstrap.sh` | `darwin-rebuild switch` 対応 |

### 変更なし

- `home/common.nix`
- `scripts/apply.sh`

## flake.nix

### inputs

```nix
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
```

### outputs

`homeConfigurations` を廃止し `darwinConfigurations` に一本化する。`localConfig` の読み込み（`--impure` + `builtins.getEnv "HOME"`）は現状維持。

```nix
outputs = { nix-darwin, home-manager, ... }:
  {
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
```

## darwin/default.nix

nix-darwin エントリポイント。home-manager との整合に必要なユーザー定義と nix 設定を管理する。

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

## darwin/system.nix

`defaults write` コマンドを3つの仕組みで移植する。

| 仕組み | 用途 |
|---|---|
| `system.defaults.*` | nix-darwin がネイティブサポートしている項目 |
| `system.defaults.CustomUserPreferences` | 任意の plist ドメインへの書き込み |
| `system.activationScripts` | `chflags` など plist で表現できないコマンド |

```nix
{ ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      AppleShowScrollBars = "Always";
      NSWindowResizeTime = 1.0e-3;  # Float 型のため指数表記
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

  # plist で表現できないコマンド
  system.activationScripts.postUserActivation.text = ''
    chflags nohidden ~/Library
  '';
  system.activationScripts.postActivation.text = ''
    chflags nohidden /Volumes
    systemsetup -setrestartfreeze on 2>/dev/null || true
  '';
}
```

## scripts/bootstrap.sh の変更

`run_home_manager` 関数を `run_darwin` に置き換え、呼び出し箇所も更新する。

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

## 適用コマンド

```bash
# 初回（nix-darwin 未インストール）
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --impure --flake .config/nix#default

# 2回目以降
darwin-rebuild switch --impure --flake .config/nix#default

# bootstrap.sh 経由
./scripts/bootstrap.sh
```

## 注意事項

- `NSWindowResizeTime` は nix-darwin で Float 型として扱うため `0.001` ではなく `1.0e-3` で記述
- `systemsetup -setrestartfreeze on` は macOS バージョンによって廃止されている可能性があるため `|| true` でエラーを無視
- 初回適用時は `darwin-rebuild` がないため `nix run nix-darwin` で起動する
