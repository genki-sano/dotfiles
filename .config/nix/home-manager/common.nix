{ pkgs, ... }:
{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fd
    git
    jq
    mise
    neovim
    ripgrep
  ];

  home.file = {
    ".oh-my-zsh".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ".config/oh-my-zsh/custom/themes/powerlevel10k".source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    ".config/oh-my-zsh/custom/plugins/zsh-autosuggestions".source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
    ".config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting".source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
  };
}
