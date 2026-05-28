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
      # 画面下に配置
      orientation = "bottom";
      # 自動的に隠す
      autohide = true;
      # 実行中アプリのインジケーターを表示
      show-process-indicators = true;
      # 最近使ったアプリを表示
      show-recents = true;
      # アプリアイコンにしまわない
      minimize-to-application = false;
      # 最小化エフェクト
      mineffect = "genie";
      # スタックをマウスオーバーでハイライト
      mouse-over-hilite-stack = true;
      # 起動中のアプリのみ表示しない
      static-only = false;
    };

    # --------------------------------------------------
    # Finder
    # --------------------------------------------------
    finder = {
      # すべての拡張子を表示
      AppleShowAllExtensions = true;
      # 隠しファイルを表示しない
      AppleShowAllFiles = false;
      # ステータスバーを表示
      ShowStatusBar = true;
      # パスバーを表示
      ShowPathbar = true;
      # デスクトップにハードドライブを表示しない
      ShowHardDrivesOnDesktop = false;
      # 外部ドライブをデスクトップに表示しない
      ShowExternalHardDrivesOnDesktop = false;
      # リムーバブルメディアをデスクトップに表示
      ShowRemovableMediaOnDesktop = true;
      # マウント済みサーバーをデスクトップに表示しない
      ShowMountedServersOnDesktop = false;
      # デフォルトをリスト表示に
      FXPreferredViewStyle = "Nlsv";
      # フォルダを先頭に並べない
      _FXSortFoldersFirst = false;
      # 検索スコープ（現在のフォルダ内）
      FXDefaultSearchScope = "SCev";
      # 拡張子変更時に警告
      FXEnableExtensionChangeWarning = true;
      # タイトルバーに POSIX パスを表示しない
      _FXShowPosixPathInTitle = false;
      # 新しいウィンドウのデフォルトをホームに
      NewWindowTarget = "Home";
    };

    # --------------------------------------------------
    # グローバル設定
    # --------------------------------------------------
    NSGlobalDomain = {
      # ダークモード
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
      # ナチュラルスクロール方向
      "com.apple.swipescrolldirection" = true;
      # スクロールバーを自動表示
      AppleShowScrollBars = "Automatic";
      # スクロールバークリックで次ページに移動しない
      AppleScrollerPagingBehavior = false;
      # ウィンドウアニメーション
      NSAutomaticWindowAnimationsEnabled = true;
      # メニューバーを隠さない
      _HIHideMenuBar = false;
      # 12時間表示
      AppleICUForce24HourTime = false;
      # 単位をセンチメートルに
      AppleMeasurementUnits = "Centimeters";
      # メートル法を使用
      AppleMetricUnits = 1;
      # 保存ダイアログを展開表示
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      # 印刷ダイアログを展開表示
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      # 新規書類をクラウドに保存しない
      NSDocumentSaveNewDocumentsToCloud = false;
      # スクロールアニメーション
      NSScrollAnimationEnabled = true;
      # フォーカスリングのアニメーション
      NSUseAnimatedFocusRing = true;
      # テーブルビューのデフォルトサイズ（中）
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
      # 3本指ドラッグを無効
      TrackpadThreeFingerDrag = false;
      # クリック感度を最小
      ActuationStrength = 0;
    };

    # --------------------------------------------------
    # スクリーンショット
    # --------------------------------------------------
    screencapture = {
      # クリップボードに保存
      target = "clipboard";
      # ファイル保存先
      location = "~/Pictures/Screenshots";
      # PNG 形式
      type = "png";
      # ウィンドウの影を含める
      disable-shadow = false;
      # サムネイルを表示
      show-thumbnail = true;
    };

    # --------------------------------------------------
    # スクリーンセーバー
    # --------------------------------------------------
    screensaver = {
      # 解除時にパスワード不要
      askForPassword = false;
      askForPasswordDelay = 0;
    };

    # --------------------------------------------------
    # ログインウィンドウ
    # --------------------------------------------------
    loginwindow = {
      # ゲストユーザーを無効
      GuestEnabled = false;
    };

    # --------------------------------------------------
    # メニューバーの時計
    # --------------------------------------------------
    menuExtraClock = {
      # 日付を非表示
      ShowDate = 0;
      # 曜日を表示
      ShowDayOfWeek = true;
      # 秒を非表示
      ShowSeconds = false;
      # 12時間表示
      Show24Hour = false;
      # AM/PM を表示
      ShowAMPM = true;
      # デジタル表示
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
      # ウィンドウマネージャーを無効
      GloballyEnabled = false;
    };

    # --------------------------------------------------
    # その他
    # --------------------------------------------------
    LaunchServices = {
      # ダウンロードしたファイルの検疫警告を無効
      LSQuarantine = false;
    };

    SoftwareUpdate = {
      # macOS の自動アップデートを無効
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

      # ヘルプビューアをデベロッパーモードで開く
      "com.apple.helpviewer" = {
        DevMode = true;
      };

      # トラックパッドの速度設定
      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 5.0;
      };

      # トラックパッドのドラッグを有効（ロックなし）
      "com.apple.AppleMultitouchTrackpad" = {
        Dragging = true;
        DragLock = false;
      };

      # Bluetooth トラックパッドのドラッグを有効（ロックなし）
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        Dragging = true;
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
