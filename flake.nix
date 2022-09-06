{
  inputs = {
    nixpkgs.url = "nixpkgs";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    server-src = {
      url = "github:katzenpost/katzenpost/v0.0.11";
      flake = false;
    };
    client-src = {
      url = "github:katzenpost/katzen/main";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    gomod2nix,
    server-src,
    client-src,
  }: let
    supportedSystems = ["x86_64-linux"];
    forSystems = systems: fun: nixpkgs.lib.genAttrs systems fun;
    forAllSystems = forSystems supportedSystems;
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [
          gomod2nix.overlays.default
          self.overlays.default
        ];
      });
  in {
    overlays.default = final: prev: {
      katzenpost-server =
        final.callPackage
        ./packages/katzenpost-server.nix {
          src = server-src;
        };
      katzenpost-authority =
        final.callPackage
        ./packages/katzenpost-authority.nix {
          src = server-src;
        };
      katzen =
        final.callPackage
        ./packages/katzen.nix {
          src = client-src;
        };
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in rec {
      inherit
        (pkgs)
        katzenpost-server
        katzenpost-authority
        katzen
        ;
      default = pkgs.symlinkJoin {
        name = "katzenpost";
        paths = [
          katzenpost-server
          katzenpost-authority
          katzen
        ];
      };
    });

    apps = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      update = pkgs.callPackage ./packages/update.nix {
        inherit server-src client-src;
      };
    in {
      update = {
        type = "app";
        program = "${update}/bin/update-nixified-dependencies";
      };
    });

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    hydraJobs = forAllSystems (system: let
      pkgs = self.packages.${system};
    in {
      build-katzenpost-server = pkgs.katzenpost-server;
      build-katzenpost-authority-voting =
        pkgs.katzenpost-authority.override {voting = true;};
      build-katzenpost-authority-nonvoting =
        pkgs.katzenpost-authority.override {voting = false;};
    });
  };
}
