{ lib, ... }:
{
  options.hostSpec = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username for this host";
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "Home directory path for this host";
    };
  };
}
