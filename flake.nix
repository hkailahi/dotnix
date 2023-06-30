{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flox.url = "git+ssh://git@github.com/flox/flox?ref=latest";
    flox.inputs.flox-floxpkgs.follows = "";
  };

  outputs = { nixpkgs, home-manager, ... }: let
    arch = "x86_64-darwin";
  in {
    defaultPackage.${arch} =
      home-manager.defaultPackage.${arch};

    homeConfigurations.hkailahi =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${arch};
        modules = [ ./home.nix ];
      };
    };
}
