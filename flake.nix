{
  description = "A very basic flake";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          libnng-dev = pkgs.stdenv.mkDerivation {
            name = "libnng-dev";
            version = "1.8.0";

            src = pkgs.fetchFromGitHub {
              owner = "nanomsg";
              repo = "nng";
              rev = "v1.8.0";
              sha256 = "sha256-E2uosZrmxO3fqwlLuu5e36P70iGj5xUlvhEb+1aSvOA=";
            };

            nativeBuildInputs = [ pkgs.cmake ];
          };
        in {
          default = pkgs.stdenv.mkDerivation {
            name = "SatDump";
            version = "1.2.0";

            src = pkgs.fetchFromGitHub {
              owner = "SatDump";
              repo = "SatDump";
              rev = "1.2.0";
              sha256 = "sha256-u15asHCMVf9cE4JGHpSw37B+4PW/aVfF4aDwzeg0rQ4=";
            };
            buildInputs = [
              pkgs.libpng
              pkgs.libtiff
              pkgs.fftwSinglePrec
              pkgs.glfw
              pkgs.librtlsdr
              pkgs.portaudio
              pkgs.volk
              pkgs.jemalloc
              libnng-dev
            ];
            nativeBuildInputs = [ pkgs.cmake pkgs.pkg-config ];
          };
        });
    };
}
