{ config, ... }:
{
  imports = [ ./system.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.ssl-cert-file = "/etc/nix/ca_cert.pem";
  
  nixpkgs.hostPlatform = config.hostSpec.system;

  users.users.${config.hostSpec.username} = {
    name = config.hostSpec.username;
    home = "/Users/${config.hostSpec.username}";
  };

  system.stateVersion = 6;
}
