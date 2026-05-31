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

  system.activationScripts.preActivation.text = ''
    backup_nix_darwin_conflict() {
      local path="$1"
      local backup="$path.before-nix-darwin"

      if [[ ! -e "$path" && ! -L "$path" ]]; then
        return
      fi

      if [[ -L "$path" ]]; then
        local target
        target="$(readlink "$path")"
        case "$target" in
          /run/current-system/*|/etc/static/*)
            echo "skip: $path is already managed by nix-darwin"
            return
            ;;
        esac
      fi

      if [[ -e "$backup" || -L "$backup" ]]; then
        echo "skip: backup already exists, keep $path: $backup"
        return
      fi

      echo "backup: $path -> $backup"
      mv "$path" "$backup"
    }

    backup_nix_darwin_conflict /etc/bashrc
    backup_nix_darwin_conflict /etc/zshrc
    backup_nix_darwin_conflict /etc/nix/nix.conf
  '';

  system.stateVersion = 6;
}
