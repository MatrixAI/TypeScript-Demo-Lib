{ pkgs ? import ./pkgs.nix {} }:

with pkgs;
let
  utils = callPackage ./utils.nix {};
  buildElf = arch:
    stdenv.mkDerivation rec {
      name = "${utils.basename}-${version}-linux-${arch}";
      version = utils.node2nixDev.version;
      src = "${utils.node2nixDev}/lib/node_modules/${utils.node2nixDev.packageName}";
      buildInputs = [
        nodePackages.pkg
      ];
      PKG_CACHE_PATH = utils.pkgCachePath;
      PKG_IGNORE_TAG = 1;
      buildPhase = ''
        cp ${./package.json} package.json
        pkg . \
          --targets linux-${arch} \
          --no-bytecode \
          --output out
      '';
      installPhase = ''
        cp out $out
      '';
    };
  buildExe = arch:
    stdenv.mkDerivation rec {
      name = "${utils.basename}-${version}-win32-${arch}.exe";
      version = utils.node2nixDev.version;
      src = "${utils.node2nixDev}/lib/node_modules/${utils.node2nixDev.packageName}";
      buildInputs = [
        nodePackages.pkg
      ];
      PKG_CACHE_PATH = utils.pkgCachePath;
      PKG_IGNORE_TAG = 1;
      buildPhase = ''
        cp ${./package.json} package.json
        pkg . \
          --targets win-${arch} \
          --no-bytecode \
          --output out.exe
      '';
      installPhase = ''
        cp out.exe $out
      '';
      dontFixup = true;
    };
  buildMacho = arch:
    stdenv.mkDerivation rec {
      name = "${utils.basename}-${version}-macos-${arch}.exe";
      version = utils.node2nixDev.version;
      src = "${utils.node2nixDev}/lib/node_modules/${utils.node2nixDev.packageName}";
      buildInputs = [
        nodePackages.pkg
      ];
      PKG_CACHE_PATH = utils.pkgCachePath;
      PKG_IGNORE_TAG = 1;
      buildPhase = ''
        cp ${./package.json} package.json
        pkg . \
          --targets macos-${arch} \
          --no-bytecode \
          --output out
      '';
      installPhase = ''
        cp out $out
      '';
      dontFixup = true;
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
          elf = buildElf "x64";
        };
      };
      windows = {
        x64 = {
          exe = buildExe "x64";
        };
      };
      macos = {
        x64 = {
          macho = buildMacho "x64";
        };
      };
    };
  }
