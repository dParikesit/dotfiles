# nix develop

{
  description = "A Nix-flake-based Java development environment";

  inputs = {
    nixpkgs2405.url = "github:nixos/nixpkgs/b134951a4c9f3c995fd7be05f3243f8ecd65d798";
  };
  outputs = { self, nixpkgs2405 }:
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
      devShells = forEachSupportedSystem ({ pkgs, pkgs2405 }: {
        default = pkgs2405.mkShell {
          packages = with pkgs2405; [
            zip
            cpio
            file
            which
            perl
            zlib
            cups
            freetype
            alsa-lib
            libjpeg
            giflib
            xorg.libX11
            xorg.libX11.dev
            xorg.libICE
            xorg.libXext
            xorg.libXrender
            xorg.libXtst
            xorg.libXt 
            xorg.libXtst
            xorg.libXi
            xorg.libXinerama
            xorg.libXcursor
            xorg.libXrandr
            fontconfig
            openjdk8-bootstrap
            libffi
          ] ++ [
            pkgs2405.gcc6
          ];

          shellHook = ''
            gcc --version
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
              with pkgs2405;
              lib.makeLibraryPath [
                libGL
                xorg.libX11
                xorg.libX11.dev
                xorg.libICE
                xorg.libXext
                xorg.libXrender
                xorg.libXtst
                xorg.libXt 
                xorg.libXtst
                xorg.libXi
                xorg.libXinerama
                xorg.libXcursor
                xorg.libXrandr
                libffi
              ]
            }"
          '';
        };
      });
    };
}
