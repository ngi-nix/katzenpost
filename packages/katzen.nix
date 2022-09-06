{
  src,
  buildGoApplication,
  lib,
  pkg-config,
  libglvnd,
  glib,
  libxkbcommon,
  xorg,
  mesa,
  wayland,
  vulkan-loader,
  vulkan-headers,
}:
buildGoApplication rec {
  pname = "katzen";
  version = "master";

  inherit src;
  modules = ../deps/client.toml;

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    libglvnd
    glib
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    mesa
    wayland
    vulkan-loader
    vulkan-headers
  ];

  meta = with lib; {
    homepage = "https://github.com/katzenpost/server";
    description = "A library for implementing the server side of the Katzenpost mix network: mixes and providers.";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [magic_rb];
  };
}
