{ pkgs ? import ./pkgs.nix {} }:

with pkgs;
rec {
  application = callPackage ./nix/default.nix {};
  docker = dockerTools.buildImage {
    name = application.name;
    contents = [ application ];
    extraCommands = ''
      mkdir -m 1777 tmp
    '';
    config = {
      Cmd = [ "/bin/typescript-demo-lib" ];
    };
  };
}
