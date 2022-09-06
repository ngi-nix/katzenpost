{
  src,
  buildGoModule,
  lib,
}:
buildGoModule {
  pname = "katzenpost-server";
  version = "0.0.11";

  inherit src;
  vendorSha256 = "sha256-qTPXpKovcocKdMUOP6zQHQMySwdqVSXFTdaX5mjpTLU=";

  subPackages = [
    "server/cmd/server"
  ];

  postInstall = ''
    mv $out/bin/server $out/bin/katzenpost-server
  '';

  meta = with lib; {
    homepage = "https://github.com/katzenpost/server";
    description = "A library for implementing the server side of the Katzenpost mix network: mixes and providers.";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [magic_rb];
  };
}
