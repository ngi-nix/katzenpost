{ src
, buildGoApplication
, fetchFromGitHub
, lib

, voting ? true
}:

buildGoApplication {
  pname = "katzenpost-authority";
  version = "0.0.11";

  inherit src;
  modules = ../deps/gomod2nix.toml;

  subPackages = [
    ("authority/" + (if voting then "cmd/voting" else "cmd/nonvoting"))
  ];

  postInstall = ''
    mv $out/bin/${if voting then "voting" else "nonvoting"} $out/bin/katzenpost-authority
  '';

  meta = with lib; {
    homepage = "https://github.com/katzenpost/authority";
    description = "Katzenpost mix network directory authority/PKI library.";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ magic_rb ];
  };
}
