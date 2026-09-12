{
  description = "Nix package for tatr, tsoding's file-based task tracker";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    tatr-src = {
      url = "github:tsoding/tatr";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      tatr-src,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Upstream has no releases; follow nixpkgs' convention for untagged sources.
      version = "0-unstable-${tatr-src.lastModifiedDate}";
    in
    {
      overlays.default = final: _prev: {
        tatr = final.callPackage ./package.nix {
          src = tatr-src;
          inherit version;
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        in
        {
          inherit (pkgs) tatr;
          default = pkgs.tatr;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.tatr ];
            packages = [ pkgs.gdb ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
