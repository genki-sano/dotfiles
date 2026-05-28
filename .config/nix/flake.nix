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
      localConfigPath = ./local.nix;
      localConfig =
        if !builtins.pathExists localConfigPath then
          throw ''
            Missing local Nix settings: .config/nix/local.nix

            Create it from:
              cp ./.config/nix/local.nix.example ./.config/nix/local.nix

            Then edit username and homeDirectory for this Mac.
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
