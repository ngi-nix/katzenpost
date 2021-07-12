{ buildGoApplication
, fetchFromGitHub
}:
let
  version = "0.0.21";
in
buildGoApplication {
  pname = "katzenpost-server";
  inherit version;

  subPackages = [
    "cmd/server"
  ];

  modules = ../gomod2nix/katzenpost-server.toml;

  postInstall = ''
    mv $out/bin/server $out/bin/katzenpost-server
  '';

  src = fetchFromGitHub {
    owner = "katzenpost";
    repo = "server";
    rev = "v" + version;
    sha256 = "sha256-gvb7y484/ONfcRFkls2Mx/RfbySrdw7oD6hQ755m7w8=";
  };

  meta = with lib; {
    homepage = "https://github.com/katzenpost/server";
    description = "A library for implementing the server side of the Katzenpost mix network: mixes and providers.";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ magic_rb ];
  };
}
