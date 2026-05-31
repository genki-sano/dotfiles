{ config, osConfig, ... }:
let
  dotfilesDir = osConfig.hostSpec.dotfilesDirectory;
  dotfile = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";
in
{
  xdg.enable = true;

  xdg.configFile = {
    "zsh".source = dotfile ".config/zsh";
    "nvim".source = dotfile ".config/nvim";
    "wezterm".source = dotfile ".config/wezterm";
    "ghostty".source = dotfile ".config/ghostty";
  };

  home.file = {
    ".zshrc".source = dotfile ".zshrc";
    ".zprofile".source = dotfile ".zprofile";
    ".vimrc".source = dotfile ".vimrc";
  };
}
