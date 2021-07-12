{
  inputs = {
    nixpkgs.url = "nixpkgs";
    gomod2nix ={
      url = "github:tweag/gomod2nix";
      inputs."nixpkgs".follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, self, gomod2nix }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems' = systems: fun: nixpkgs.lib.genAttrs systems fun;
      forAllSystems = forAllSystems' supportedSystems;
    in
    {
      overlays.katzenpost = final: prev:
        {
          katzenpost-server = final.callPackage ./packages/katzenpost-server.nix {}; 
          katzenpost-authority = final.callPackage ./packages/katzenpost-authority.nix {}; 
          catshadow = final.callPackage ./packages/catshadow.nix {}; 
          catchat = final.callPackage ./packages/catchat.nix {}; 
        };

      hydraJobs = forAllSystems (system:
        let
          pkgs = self.packages.${system};
        in {
          build-katzenpost-server = pkgs.katzenpost-server;
          build-katzenpost-authority-voting = pkgs.katzenpost-authority.override { voting = true; };
          build-katzenpost-authority-nonvoting = pkgs.katzenpost-authority.override { voting = false; };
        });

      defaultPackage = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ gomod2nix.overlay self.overlays.katzenpost ]; };
        in
          pkgs.symlinkJoin
            { name = "katzenpost";
              paths = with pkgs; 
                [ katzenpost-server
                  katzenpost-authority
                  catchat
                ];
            }
      ); 

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ gomod2nix.overlay self.overlays.katzenpost ]; };
        in
          {
            inherit (pkgs)
              katzenpost-server
              katzenpost-authority
              catchat;
          }
      );
    };
}
