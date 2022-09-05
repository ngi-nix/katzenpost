{
  inputs = {
    nixpkgs.url = "nixpkgs";
    gomod2nix = {
      url = "github:nix-community/gomod2nix/v1.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    src = {
      url = "github:katzenpost/katzenpost/v0.0.11";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, gomod2nix, src }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forSystems = systems: fun: nixpkgs.lib.genAttrs systems fun;
      forAllSystems = forSystems supportedSystems;
    in
      with nixpkgs.lib;
      {
        overlays.katzenpost = final: prev:
          {
            katzenpost-server = final.callPackage ./packages/katzenpost-server.nix { inherit src; };
            katzenpost-authority = final.callPackage ./packages/katzenpost-authority.nix { inherit src; };

            update = final.callPackage ./packages/update.nix { inherit src; };
          };

        defaultPackage = forAllSystems (system:
          let
            pkgs = import nixpkgs { inherit system; overlays = [
              gomod2nix.overlays.default
              self.overlays.katzenpost
            ]; };
          in
            pkgs.symlinkJoin
              { name = "katzenpost";
                paths = with pkgs; [
                  katzenpost-server
                  katzenpost-authority
                ];
              }
        );

        packages = forAllSystems (system:
          let
            pkgs = import nixpkgs { inherit system; overlays = [
              gomod2nix.overlays.default
              self.overlays.katzenpost
            ]; };
          in
            {
              inherit (pkgs)
                katzenpost-server
                katzenpost-authority
                update;
            }
        );

        apps = forAllSystems (system: rec {
          update = {
            type = "app";
            program = "${self.packages.${system}.update}/bin/update-nixified-dependencies";
          };
        });

        hydraJobs = forAllSystems (system:
          let
            pkgs = self.packages.${system};
          in {
            build-katzenpost-server = pkgs.katzenpost-server;
            build-katzenpost-authority-voting = pkgs.katzenpost-authority.override { voting = true; };
            build-katzenpost-authority-nonvoting = pkgs.katzenpost-authority.override { voting = false; };
          });
      };
}
