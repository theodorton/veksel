{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    nixpkgs-ruby,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {inherit system;};
        lib = pkgs.lib;
        rubyVersion = lib.strings.removeSuffix "\n" (builtins.readFile ./.ruby-version);
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-ruby.packages.x86_64-linux."ruby-${rubyVersion}"
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
