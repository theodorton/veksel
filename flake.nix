{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      ruby = pkgs.ruby_4_0;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          ruby
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

      # `nix flake check` fails if the devShell's ruby drifts from .ruby-version.
      checks.ruby-version =
        pkgs.runCommand "check-ruby-version" {
          nativeBuildInputs = [ruby];
          rubyVersionFile = ./.ruby-version;
        } ''
          expected=$(tr -d '[:space:]' < "$rubyVersionFile")
          actual=$(ruby --version | cut -d' ' -f2)
          if [ "$actual" != "$expected" ]; then
            echo "ruby version mismatch: devShell provides $actual, .ruby-version pins $expected" >&2
            exit 1
          fi
          touch $out
        '';
    });
}
