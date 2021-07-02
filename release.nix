{ pkgs ? import ./pkgs.nix {} }:

with pkgs;
let
  utils = callPackage ./utils.nix {};
  # buildExe = arch:
  #   stdenv.mkDerivation rec {
  #     name = "${utils.basename}-${version}-win32-${arch}.exe";
  #     version = utils.node2nixDev.version;
  #     src = "${utils.node2nixDev}/lib/node_modules/${utils.node2nixDev.packageName}";
  #     buildInputs = [
  #       nodePackages."pkg"
  #     ];
  #     PKG_CACHE_DIR = utils.pkgCacheDir;
  #     buildPhase = ''
  #       # try building using pkg
  #     '';
  #     installPhase = ''
  #       # copy the executable into the $out
  #     '';
  #   };
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
    x = utils.pkgCacheDir;
    # package = {
    #   linux = {
    #     x64 = {
    #       elf = "";
    #     };
    #     ia32 = {
    #       elf = "";
    #     };
    #   };
    #   windows = {
    #     x64 = {
    #       exe = "";
    #     };
    #     ia32 = {
    #       exe = "";
    #     };
    #   };
    #   darwin = {
    #     x64 = {
    #       mach-o = "";
    #     };
    #     arm64 = {
    #       mach-o = "";
    #     };
    #   };
    # };
  }
