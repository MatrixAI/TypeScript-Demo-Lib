{ pkgs, lib, nix-gitignore }:

let
  nodejs = pkgs."nodejs-12_x";
  nodeDependencies = (pkgs.callPackage ./generated/node-composition.nix {}).shell.nodeDependencies;
in
  pkgs.stdenv.mkDerivation {
    name = "demo-app";
    src = nix-gitignore.gitignoreSource [] ../.;
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    buildInputs = [nodejs];
    buildPhase = ''
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"

      # Build the distribution bundle in "dist"
      npm run build
    '';
    installPhase = ''
      mkdir -p $out
      cp -r bin $out
      cp -r dist $out
    '';
  }
