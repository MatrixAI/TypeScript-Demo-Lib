{ pkgs ? import ./pkgs.nix {} }:

with pkgs;
let
  buildExe = arch:
    stdenv.mkDerivation rec {
      # we need to know what the name of what we want to do is
      # plus
      name = "";
    };
in
  rec {
    application = callPackage ./default.nix {};
    docker = dockerTools.buildImage {
      name = application.name;
      contents = [ application ];
      keepContentsDirlinks = true;
      extraCommands = ''
        mkdir -m 1777 tmp
      '';
      config = {
        Cmd = [ "/bin/typescript-demo-lib" ];
      };
    };
    package = {
      linux = {
        x64 = {
          elf = "";
        };
        ia32 = {
          elf = "";
        };
      };
      windows = {
        x64 = {
          exe = "";
        };
        ia32 = {
          exe = "";
        };
      };
      darwin = {
        x64 = {
          mach-o = "";
        };
        arm64 = {
          mach-o = "";
        };
      };
    };
  }
