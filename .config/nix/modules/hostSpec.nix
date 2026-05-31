{ lib, config, ... }:
{
  options.hostSpec = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username for this host";
    };
    system = lib.mkOption {
      type = lib.types.str;
      description = "System architecture";
    };
    dotfilesDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/Users/${config.hostSpec.username}/dotfiles";
      description = "Path to the dotfiles checkout";
    };
  };
}
