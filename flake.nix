{
  description = "LV2 impulse loader";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        plugin = pkgs.stdenv.mkDerivation rec {
       	  pname = "impulseloader-lv2";
       	  version = "0.4";

       	  src = pkgs.fetchFromGitHub {
       	    owner = "brummer10";
       	    repo = "ImpulseLoader";
       	    tag = "v${version}";
       	    hash = "sha256-NdbhOzaUCPHAD9RfGcHEuFxAZlQ4+hf7P3SF7hAd+UA=";
       	    fetchSubmodules = true;
       	  };

       	  nativeBuildInputs = with pkgs; [
       	    pkg-config
       	  ];

       	  buildInputs = with pkgs; [
       	    cairo
            libsndfile
            libX11
            lv2
            fftw
            fftwFloat
       	  ];

          installPhase = ''
            mkdir -p $out/lib/lv2
            cp -r bin/ImpulseLoader.lv2 $out/lib/lv2
          '';
        };

        wiring = ./impulse-loader.carxp;
    in
      {
        packages.default = plugin;

        devShells.default = pkgs.mkShell {
          packages = [
            plugin
            pkgs.carla
          ];

          shellHook = ''
            export LV2_PATH="${plugin}/lib/lv2:$LV2_PATH"
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "carla-ir" ''
            export LV2_PATH=${plugin}/lib/lv2;
            exec ${pkgs.carla}/bin/carla --load ${wiring}
          '';
        };
      }

  );
}
