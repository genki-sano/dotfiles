{ lib, ... }:
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
  };
}
