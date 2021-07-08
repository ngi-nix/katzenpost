{ buildGoApplication
, fetchFromGitHub
, go
}:
let
  version = "0.0.30";

  qt = buildGoApplication {
    pname = "go-qt";
    version = "master";

    modules = ../gomod2nix/qt.toml;

    postUnpack = ''
      export file="source/internal/binding/files/docs/mod.go"
      rm $file && printf 'package docs' > $file
      printf 'package internal' > source/internal/mod.go
    '';

    subPackages = [
      "cmd/qtdeploy"
    ];

    src = fetchFromGitHub {
      owner = "therecipe";
      repo = "qt";
      rev = "c0c124a5770d357908f16fa57e0aa0ec6ccd3f91";
      sha256 = "sha256-LSOm6/P1fOO3jlwxMm78mJMH7iuNvbBuE688sAVs/KQ=";
    };
  };
in
buildGoApplication {
  pname = "catchat";
  inherit version;

  modules = ../gomod2nix/catchat.toml;

  src = fetchFromGitHub {
    owner = "katzenpost";
    repo = "catchat";
    rev = "v" + version;
    sha256 = "sha256-llSNlavbZ5zjdcGUlTqfv6NUlGx/SbF7T47WySmNFOo=";
  };
}
