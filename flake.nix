{
  description = "LV2 impulse loader";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =  { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
     	packages.${system}.default = pkgs.stdenv.mkDerivation rec {
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

        buildPhase = ''
          FFTW3F_LIB=${pkgs.fftwFloat.out}/lib

          sed -i "s/-lfftw3f/-L$FFTW3F -lfftw3f/g" makefile

          export CXXFLAGS="$(pkg-config --cflags cairo lv2 fftw3)"
          export LDFLAGS="$(pkg-config --libs cairo lv2 fftw3)"

          make
        '';

        installPhase = ''
          mkdir -p $out/lib/lv2
          cp -r ./bin/ImpulseLoader.lv2 $out/lib/lv2
        '';
  	};
	};
}
