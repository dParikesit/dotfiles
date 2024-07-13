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
          ];

          shellHook = ''
            gcc --version
          '';
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
          pname = "WeBridge";

          src = ~/OpenJDK-Concolic-Execution-Engine;

          nativeBuildInputs = [
            pkgs.gcc6
          ];

          buildPhase = ''
            ./scripts/install_dependencies.sh || exit
            ./scripts/configure.sh || exit
            make all -j CONF=linux-x86_64-normal-zero-release || exit
            rm -rf ~/webridge || exit
            cp -r ./build/linux-x86_64-normal-zero-release/images/j2sdk-image ~ || exit
            mv ~/j2sdk-image webridge || exit
          '';
        };
      });
    };
}