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
            contents = [self.packages.${system}.default];
            config = {
              #Cmd = ["${self.packages.${system}.default}/bin/python3"];
              #Args = ["-m" "${self.packages.${system}.default}"];
              ExposedPorts = {"8010/tcp" = {};};
            };
          };
          default = (with pkgs; stdenv.mkDerivation {
            inherit system name src;
            buildInputs = with pkgs.python312Packages; [
              flask
              requests
              pyyaml
              pillow
              pkgs.coreutils
            ];
            installPhase = ''
              mkdir -p $out
              cp -r $src/ycast/* $out
            '';
          });
        };
      }
    );
}
