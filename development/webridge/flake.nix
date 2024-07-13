# nix build -L .#jdk
# nix develop --build
# nix develop

{
  description = "A Nix-flake-based Java development environment";

  inputs = {
    nixpkgs.follows = "nixpkgs";
  };

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
      });

      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
          pname = "WeBridge";

          src = ~/OpenJDK-Concolic-Execution-Engine;

          nativeBuildInputs = [
            gcc6
          ];

          buildPhase = ''
            ./scripts/install_dependencies.sh
            ./scripts/configure.sh
            make all -j CONF=linux-x86_64-normal-zero-release
            rm -rf ~/webridge
            cp -r ./build/linux-x86_64-normal-zero-release/images/j2sdk-image ~
            mv ~/j2sdk-image webridge
          ''
        };
      });
    };
}