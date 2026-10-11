{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {inherit system overlays;};
        rust-toolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
          toolchain.default.override {
            extensions = ["rust-src" "llvm-tools-preview"];
            targets = ["aarch64-unknown-none" "x86_64-unknown-none"];
          });
      in {
        packages = {};

        apps = {};

        devShells.default = pkgs.mkShell {
          buildInputs = [rust-toolchain pkgs.qemu pkgs.cargo-bootimage];
        };
      }
    );
}
