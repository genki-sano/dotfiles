{ lib, config, ... }:
{
  system.primaryUser = config.hostSpec.username;

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "";
    interactiveShellInit = lib.mkForce "";
  };
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      tilesize = 34;
      magnification = true;
      largesize = 65;
      orientation = "bottom";
      autohide = true;
      show-process-indicators = true;
      show-recents = true;
      minimize-to-application = false;
      mineffect = "genie";
      mouse-over-hilite-stack = true;
      static-only = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = false;
      FXPreferredViewStyle = "Nlsv";
      _FXSortFoldersFirst = false;
      FXDefaultSearchScope = "SCev";
      FXEnableExtensionChangeWarning = true;
      _FXShowPosixPathInTitle = false;
      NewWindowTarget = "Home";
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 1;
      InitialKeyRepeat = 12;
      NSAutomaticSpellingCorrectionEnabled = true;
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticDashSubstitutionEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSAutomaticQuoteSubstitutionEnabled = true;
      "com.apple.swipescrolldirection" = true;
      AppleShowScrollBars = "Automatic";
      AppleScrollerPagingBehavior = false;
      NSAutomaticWindowAnimationsEnabled = true;
      _HIHideMenuBar = false;
      AppleICUForce24HourTime = false;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSScrollAnimationEnabled = true;
      NSUseAnimatedFocusRing = true;
      NSTableViewDefaultSizeMode = 2;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      ActuationStrength = 0;
    };

    screencapture = {
      target = "clipboard";
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = false;
      show-thumbnail = true;
    };

    screensaver = {
      askForPassword = false;
      askForPasswordDelay = 0;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    menuExtraClock = {
      ShowDate = 0;
      ShowDayOfWeek = true;
      ShowSeconds = false;
      Show24Hour = false;
      ShowAMPM = true;
      IsAnalog = false;
    };

    spaces = {
      spans-displays = true;
    };

    WindowManager = {
      GloballyEnabled = false;
    };

    LaunchServices = {
      LSQuarantine = false;
    };

    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = false;
    };

    CustomUserPreferences = {
      "com.apple.BluetoothAudioAgent" = {
        "Apple Bitpool Min (editable)" = 40;
      };
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
      "com.apple.CrashReporter" = {
        DialogType = "none";
      };
      "com.apple.helpviewer" = {
        DevMode = true;
      };
      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 5.0;
      };
      "com.apple.AppleMultitouchTrackpad" = {
        Dragging = true;
        DragLock = false;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        Dragging = true;
        DragLock = false;
      };
    };

    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 5.0;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

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
