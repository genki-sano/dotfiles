{
  description = "dotfiles managed with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nix-darwin, home-manager, ... }:
    let
      homeDir = builtins.getEnv "HOME";
      localConfigPath = "${homeDir}/.config/dotfiles/local.nix";
      localConfig =
        if homeDir == "" then
          throw ''
            HOME is not available during flake evaluation.

            Run with --impure so ~/.config/dotfiles/local.nix can be read.
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
    in {
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit localConfig; };
        modules = [
          ./darwin/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${localConfig.username} = import ./home/common.nix;
          }
        ];
      };
    };
}
