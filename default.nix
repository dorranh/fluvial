{ compiler ? "ghc865" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "fluvial" =
        hself.callCabal2nix
          "fluvial"
          (gitignore ./.)
          {};
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [
      p."fluvial"
    ];
    buildInputs = with pkgs.haskellPackages; [
      myHaskellPackages.cabal-install
      ghcide
      ormolu
      hlint
      zlib
      (import sources.niv {}).niv
      pkgs.nixpkgs-fmt
    ];
    withHoogle = true;
  };

  exe = pkgs.haskell.lib.justStaticExecutables (myHaskellPackages."fluvial");

  docker = pkgs.dockerTools.buildImage {
    name = "fluvial";
    config.Cmd = [ "${exe}/bin/fluvial" ];
  };
in
{
  inherit shell;
  inherit exe;
  inherit docker;
  inherit myHaskellPackages;
  "fluvial" = myHaskellPackages."fluvial";
}
