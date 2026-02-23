{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    nixpkgs-ruby,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      lib = pkgs.lib;
    in {
      devShells.default = let
        rubyVersion = lib.strings.removeSuffix "\n" (builtins.readFile ./.ruby-version);
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-ruby.packages.${system}."ruby-${rubyVersion}"
            libyaml
            libffi
            libjson
            openssl
            zlib
          ];
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          BUNDLE_PATH = "vendor/bundle";
          BUNDLE_CLEAN = "1";
        };

      devShells.ruby4 = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-ruby.packages.${system}."ruby-4.0.0"
          libyaml
          libffi
          libjson
          openssl
          zlib
        ];
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        BUNDLE_PATH = "vendor/bundle";
        BUNDLE_CLEAN = "1";
      };
    });
}
