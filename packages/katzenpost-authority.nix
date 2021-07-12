{ buildGoApplication
, fetchFromGitHub

, voting ? true
}:
let
  version = "0.0.18";
in
buildGoApplication {
  pname = "katzenpost-authority";
  inherit version;

  subPackages = [
    (if voting then "cmd/voting" else "cmd/nonvoting")
  ];

  modules = ../gomod2nix/katzenpost-authority.toml;

  postInstall = ''
    mv $out/bin/${if voting then "voting" else "nonvoting"} $out/bin/katzenpost-authority
  '';

  src = fetchFromGitHub {
    owner = "katzenpost";
    repo = "authority";
    rev = "v" + version;
    sha256 = "sha256-hC/huErdgTUHZJQ/BSRPhIK9pYQ8xO5fgyP5QCKykr4=";
  };

  meta = with lib; {
    homepage = "https://github.com/katzenpost/authority";
    description = "Katzenpost mix network directory authority/PKI library.";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ magic_rb ];
  };
}
