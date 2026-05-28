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

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      mkApp = name: script: {
        type = "app";
        program = "${pkgs.writeShellApplication {
          inherit name;
          text = script;
        }}/bin/${name}";
      };
    in {
      apps.${system} = {
        switch = mkApp "darwin-switch" ''
          sudo darwin-rebuild switch --flake "${self}#default"
        '';
        build = mkApp "darwin-build" ''
          darwin-rebuild build --flake "${self}#default"
        '';
      };

      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./modules/hostSpec.nix
          ./hosts/default.nix
          ./darwin/default.nix
          home-manager.darwinModules.home-manager
          ({ config, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${config.hostSpec.username} = import ./home/common.nix;
          })
        ];
      };
    };
}
