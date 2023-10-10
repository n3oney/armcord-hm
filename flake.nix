{
  description = "A Home-Manager module for setting up ArmCord with your configuration in Nix.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        inputs,
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = {
          leveldb-cli = pkgs.callPackage ./leveldb-cli.nix {};
        };
      };

      flake = _: {
        homeManagerModules = rec {
          armcord-hm = import ./hm-module.nix inputs.self;
          default = armcord-hm;
        };
      };
    };
}
