{ buildGoModule
, fetchFromGitHub
}:
let
  version = "0.0.48";
in
buildGoModule {
  pname = "catshadow";
  inherit version;

  vendorSha256 = null;

  subPackages = [
    (if voting then "cmd/voting" else "cmd/nonvoting")
  ];

  src = fetchFromGitHub {
    owner = "katzenpost";
    repo = "authority";
    rev = "v" + version;
    sha256 = "sha256-hC/huErdgTUHZJQ/BSRPhIK9pYQ8xO5fgyP5QCKykr4=";
  };
}
