{ localConfig, ... }:
{
  system.primaryUser = localConfig.username;

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
    chflags nohidden /Users/${localConfig.username}/Library
    chflags nohidden /Volumes
    systemsetup -setrestartfreeze on 2>/dev/null || true
  '';
}
