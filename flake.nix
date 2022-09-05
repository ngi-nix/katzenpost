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

  outputs = {
    self,
    nixpkgs,
    gomod2nix,
    src,
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
        ./packages/katzenpost-server.nix
        {inherit src;};
      katzenpost-authority =
        final.callPackage
        ./packages/katzenpost-authority.nix
        {inherit src;};

      update =
        final.callPackage
        ./packages/update.nix
        {inherit src;};
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in rec {
      inherit
        (pkgs)
        katzenpost-server
        katzenpost-authority
        update
        ;
      default = pkgs.symlinkJoin {
        name = "katzenpost";
        paths = [
          katzenpost-server
          katzenpost-authority
        ];
      };
    });

    apps = forAllSystems (system: rec {
      update = {
        type = "app";
        program = "${self.packages.${system}.update}/bin/update-nixified-dependencies";
      };
      format = {
        type = "app";
        program = "${nixpkgsFor.${system}.alejandra}/bin/alejandra";
      };
    });

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
