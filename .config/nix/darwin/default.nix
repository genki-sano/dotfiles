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
