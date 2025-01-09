# nix develop

{
  description = "A Nix-flake-based Java development environment";

  outputs = { self, nixpkgs, nixpkgs2405 }:
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
        pkgs2405 = import nixpkgs2405 { inherit overlays system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = mkShell {
          packages = with pkgs; [
            ant
            maven
          ];

          shellHook = ''
            export JAVA_HOME="/localtmp/concolic/webridge/build/linux-x86_64-normal-zero-release/images/j2sdk-image"
            export PATH="/localtmp/concolic/webridge/build/linux-x86_64-normal-zero-release/images/j2sdk-image/bin:$PATH"
          '';
        };
        };
      });
    };
}
