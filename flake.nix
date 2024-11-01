{
  description = "YCast";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        name = "ycast";
        src = ./.;
        pkgs = nixpkgs.legacyPackages.${system};  # Check if legacyPackages is available
        version = "latest";
      in
      {
        packages = {
          docker = pkgs.dockerTools.buildLayeredImage {
            inherit name;
            tag = version;
            contents = with pkgs; [
              python312
            ];
          };
          default = (with pkgs; stdenv.mkDerivation {
            inherit system name src;
            buildInputs = with pkgs.python312Packages; [
              pkgs.python312
              flask
              requests
              pyyaml
              pillow
            ];
            installPhase = ''
              mkdir -p $out/ycast
              cp -r $src/ycast $out/
            '';
          });
        };
      }
    );
}
