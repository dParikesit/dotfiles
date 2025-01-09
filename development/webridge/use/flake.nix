# nix develop

{
  description = "A Nix-flake-based Java development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      overlays = [
      ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit overlays system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            ant
            maven
          ];

          shellHook = ''
            export JAVA_HOME="/localtmp/concolic/webridge/build/linux-x86_64-normal-zero-release/images/j2sdk-image"
            export PATH="/localtmp/concolic/webridge/build/linux-x86_64-normal-zero-release/images/j2sdk-image/bin:$PATH"
          '';
        };
      });
    };
}
