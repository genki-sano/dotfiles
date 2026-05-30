{ lib, config, ... }:
{
  system.primaryUser = config.hostSpec.username;

  # zsh の設定は別途管理するため、nix-darwin のビルトイン設定を無効化
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "";
    interactiveShellInit = lib.mkForce "";
  };

  # sudo に Touch ID を使う
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    # --------------------------------------------------
    # Dock
    # --------------------------------------------------
    dock = {
      # アイコンサイズ
      tilesize = 34;
      # マウスオーバー時に拡大
      magnification = true;
      # 拡大時のサイズ
      largesize = 65;
      # Dockの位置 ("left", "bottom", "right")
      orientation = "left";
      # 自動的に隠す
      autohide = true;
      # 実行中アプリのインジケーターを表示
      show-process-indicators = true;
      # 最近使ったアプリを表示
      show-recents = false;
      # 最小化時にアプリアイコンにしまう
      minimize-to-application = false;
      # 最小化エフェクト ("genie", "suck", "scale")
      mineffect = "genie";
      # スタックをマウスオーバーでハイライト
      mouse-over-hilite-stack = true;
      # 起動中のアプリのみ Dock に表示
      static-only = false;
    };

    # --------------------------------------------------
    # Finder
    # --------------------------------------------------
    finder = {
      # すべての拡張子を表示
      AppleShowAllExtensions = true;
      # 隠しファイルを表示
      AppleShowAllFiles = false;
      # ステータスバーを表示
      ShowStatusBar = true;
      # パスバーを表示
      ShowPathbar = true;
      # デスクトップにハードドライブを表示
      ShowHardDrivesOnDesktop = false;
      # 外部ドライブをデスクトップに表示
      ShowExternalHardDrivesOnDesktop = false;
      # リムーバブルメディアをデスクトップに表示
      ShowRemovableMediaOnDesktop = true;
      # マウント済みサーバーをデスクトップに表示
      ShowMountedServersOnDesktop = false;
      # デフォルトの表示スタイル ("icnv": アイコン, "Nlsv": リスト, "clmv": カラム, "Flwv": ギャラリー)
      FXPreferredViewStyle = "Nlsv";
      # フォルダを先頭に並べる
      _FXSortFoldersFirst = true;
      # 検索スコープ ("SCev": 現在のフォルダ, "SCcf": この Mac 全体, "SCsp": 共有ファイル)
      FXDefaultSearchScope = "SCev";
      # 拡張子変更時に警告
      FXEnableExtensionChangeWarning = true;
      # タイトルバーに POSIX パスを表示
      _FXShowPosixPathInTitle = false;
      # 新しいウィンドウのデフォルト ("Home", "Desktop", "Documents", "Recents", "Computer", "iCloud")
      NewWindowTarget = "Home";
    };

    # --------------------------------------------------
    # グローバル設定
    # --------------------------------------------------
    NSGlobalDomain = {
      # インターフェーススタイル ("Dark": ダーク, null: ライト)
      AppleInterfaceStyle = "Dark";
      # キーリピート速度（小さいほど速い）
      KeyRepeat = 1;
      # キーリピート開始までの遅延
      InitialKeyRepeat = 12;
      # スペル自動修正
      NSAutomaticSpellingCorrectionEnabled = true;
      # 自動大文字化
      NSAutomaticCapitalizationEnabled = true;
      # ダッシュの自動置換
      NSAutomaticDashSubstitutionEnabled = true;
      # ピリオドの自動置換
      NSAutomaticPeriodSubstitutionEnabled = true;
      # 引用符の自動置換
      NSAutomaticQuoteSubstitutionEnabled = true;
      # ナチュラルスクロール（指の動きと逆方向にスクロール）
      "com.apple.swipescrolldirection" = true;
      # スクロールバーの表示タイミング ("Automatic", "WhenScrolling", "Always")
      AppleShowScrollBars = "Always";
      # スクロールバークリックで次ページに移動
      AppleScrollerPagingBehavior = false;
      # ウィンドウアニメーションを有効
      NSAutomaticWindowAnimationsEnabled = true;
      # メニューバーを隠す
      _HIHideMenuBar = false;
      # 24時間表示
      AppleICUForce24HourTime = true;
      # 単位 ("Centimeters", "Inches")
      AppleMeasurementUnits = "Centimeters";
      # メートル法を使用
      AppleMetricUnits = 1;
      # 保存ダイアログを展開表示
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      # 印刷ダイアログを展開表示
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      # 新規書類をクラウドに保存
      NSDocumentSaveNewDocumentsToCloud = false;
      # スクロールアニメーションを有効
      NSScrollAnimationEnabled = true;
      # フォーカスリングのアニメーションを有効
      NSUseAnimatedFocusRing = true;
      # テーブルビューのデフォルトサイズ (1: 小, 2: 中, 3: 大)
      NSTableViewDefaultSizeMode = 2;
    };

    # --------------------------------------------------
    # トラックパッド
    # --------------------------------------------------
    trackpad = {
      # タップでクリック
      Clicking = true;
      # 2本指で右クリック
      TrackpadRightClick = true;
      # 3本指ドラッグを有効
      TrackpadThreeFingerDrag = false;
      # クリック感度（0: 最小, 1: 標準）
      ActuationStrength = 0;
    };

    # --------------------------------------------------
    # スクリーンショット
    # --------------------------------------------------
    screencapture = {
      # 保存先 ("clipboard": クリップボード, "file": ファイル, "preview": プレビュー)
      target = "clipboard";
      # ファイル保存先
      location = "~/Pictures/Screenshots";
      # ファイル形式 ("png", "jpg", "pdf", "tiff", "bmp", "gif")
      type = "png";
      # ウィンドウの影を除去
      disable-shadow = false;
      # 撮影後にサムネイルを表示
      show-thumbnail = true;
    };

    # --------------------------------------------------
    # スクリーンセーバー
    # --------------------------------------------------
    screensaver = {
      # スクリーンセーバー解除時にパスワードを要求
      askForPassword = false;
      askForPasswordDelay = 0;
    };

    # --------------------------------------------------
    # ログインウィンドウ
    # --------------------------------------------------
    loginwindow = {
      # ゲストユーザーを有効
      GuestEnabled = false;
    };

    # --------------------------------------------------
    # メニューバーの時計
    # --------------------------------------------------
    menuExtraClock = {
      # 日付表示 (0: 非表示, 1: 表示)
      ShowDate = 1;
      # 曜日を表示
      ShowDayOfWeek = true;
      # 秒を表示
      ShowSeconds = true;
      # 24時間表示
      Show24Hour = true;
      # AM/PM を表示
      ShowAMPM = false;
      # アナログ表示
      IsAnalog = false;
    };

    # --------------------------------------------------
    # Mission Control
    # --------------------------------------------------
    spaces = {
      # ディスプレイをまたいでスペースを共有
      spans-displays = true;
    };

    WindowManager = {
      # ウィンドウマネージャーを有効
      GloballyEnabled = false;
    };

    # --------------------------------------------------
    # その他
    # --------------------------------------------------
    LaunchServices = {
      # ダウンロードしたファイルの検疫警告を有効
      LSQuarantine = false;
    };

    SoftwareUpdate = {
      # macOS の自動アップデートを有効
      AutomaticallyInstallMacOSUpdates = false;
    };

    # --------------------------------------------------
    # 個別アプリ設定（CustomUserPreferences）
    # --------------------------------------------------
    CustomUserPreferences = {
      # Bluetooth 音声の最小ビットプールを設定（音質向上）
      "com.apple.BluetoothAudioAgent" = {
        "Apple Bitpool Min (editable)" = 40;
      };

      # Spotlight のキーボードショートカットを無効（他ツールと競合しないよう）
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "64" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1048576 ];
              type = "standard";
            };
          };
          "65" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1572864 ];
              type = "standard";
            };
          };
        };
      };

      # クラッシュレポートのダイアログを無効
      "com.apple.CrashReporter" = {
        DialogType = "none";
      };

      # ヘルプビューアの設定
      "com.apple.helpviewer" = {
        # デベロッパーモードで開く
        DevMode = true;
      };

      # トラックパッドの速度設定
      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3;
      };

      # トラックパッドのドラッグ設定
      "com.apple.AppleMultitouchTrackpad" = {
        # ドラッグを有効
        Dragging = true;
        # ドラッグロックを有効（指を離してもドラッグ継続）
        DragLock = false;
      };

      # Bluetooth トラックパッドのドラッグ設定
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        # ドラッグを有効
        Dragging = true;
        # ドラッグロックを有効（指を離してもドラッグ継続）
        DragLock = false;
      };
    };

    # マウスの速度設定
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 5.0;
    };
  };

  # --------------------------------------------------
  # キーボード
  # --------------------------------------------------
  system.keyboard = {
    # キーマッピングを有効
    enableKeyMapping = true;
    # CapsLock を Control に変更
    remapCapsLockToControl = true;
  };

  # --------------------------------------------------
  # Activation Scripts
  # --------------------------------------------------

  # Homebrew のパーミッション修正・Xcode CLT・Rosetta 2 のインストール
  system.activationScripts.extraActivation.text = ''
    echo "=== extraActivation: Starting ==="

    BREW_USER="${config.hostSpec.username}"
    echo "BREW_USER=$BREW_USER"

    if [[ -n "$BREW_USER" ]]; then
      if [[ ! -d "/opt/homebrew" ]]; then
        echo "Creating Homebrew directory for $BREW_USER..."
        /bin/mkdir -p /opt/homebrew
      fi
      echo "Fixing Homebrew directory permissions for $BREW_USER..."
      /usr/sbin/chown -R "$BREW_USER":admin /opt/homebrew

      if [[ -d "/usr/local/Homebrew" ]]; then
        echo "Fixing Intel Homebrew directory permissions for $BREW_USER..."
        /usr/sbin/chown -R "$BREW_USER":admin /usr/local/Homebrew
        /usr/sbin/chown -R "$BREW_USER":admin /usr/local/bin 2>/dev/null || true
      fi
    else
      echo "WARNING: BREW_USER is not set (config.hostSpec.username is empty)"
    fi

    if ! /usr/bin/xcrun -f clang >/dev/null 2>&1; then
      echo "Installing Xcode Command Line Tools..."
      touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
      PROD=$(/usr/sbin/softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
      /usr/sbin/softwareupdate -i "$PROD" --verbose
      rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    fi

    if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/pgrep -q oahd; then
      echo "Installing Rosetta 2..."
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi

    echo "=== extraActivation: Done ==="
  '';

  # Apple Music の自動起動（RCD）を無効化
  system.activationScripts.disableAppleMusicRcd.text = ''
    USER_NAME="${config.hostSpec.username}"
    if [[ -n "$USER_NAME" ]]; then
      USER_UID="$(/usr/bin/id -u "$USER_NAME")"
      if [[ -n "$USER_UID" ]]; then
        echo "Disabling com.apple.rcd for uid=$USER_UID ($USER_NAME)..."
        /bin/launchctl disable "gui/$USER_UID/com.apple.rcd" || true
      fi
    fi
  '';
}
