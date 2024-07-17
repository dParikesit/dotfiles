# nix build -L .#jdk
# nix develop --build
# nix develop

{
  description = "A Nix-flake-based Java development environment";

  outputs = { self, nixpkgs }:
    let
      javaVersion = 8; # Change this value to update the whole stack
      overlays = [
        (final: prev: rec {
          jdk = prev."jdk${toString javaVersion}";
          maven = prev.maven.override { inherit jdk; };
        })
      ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit overlays system; };
      });

      xorgLibs = with pkgs.xorg; [
        libICE
        libSM
        libX11
        libX11.dev
      ];
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            ant
            maven
          ];

          shellHook = ''
            export JAVA_HOME="~/webridge"
            export PATH="~/webridge/bin:$PATH"
          '';
        };

        jdk = pkgs.mkShell {
          packages = with pkgs; [
            gcc6
            zip
          ] ++ xorgLibs;

          shellHook = ''
            gcc --version
            LD_LIBRARY_PATH = "${lib.makeLibraryPath xorgLibs}";
          '';
        };
      });
    };
}