{
  description = "dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      homeDir = builtins.getEnv "HOME";
      localConfigPath = "${homeDir}/.config/dotfiles/local.nix";
      localConfig =
        if homeDir == "" then
          throw ''
            HOME is not available during flake evaluation.

            Run Home Manager with --impure so ~/.config/dotfiles/local.nix can be read.
          ''
        else if !builtins.pathExists localConfigPath then
          throw ''
            Missing local Nix settings: ${localConfigPath}

            Create it from:
              mkdir -p ~/.config/dotfiles
              cp ./.config/nix/local.nix.example ~/.config/dotfiles/local.nix
          ''
        else
          import localConfigPath;
      mkHome = { username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/common.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in {
      homeConfigurations = {
        default = mkHome {
          inherit (localConfig) username homeDirectory;
        };
      };
    };
}
