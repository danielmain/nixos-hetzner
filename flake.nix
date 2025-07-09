{
  description = "VisitFlow Backend and NixOS Configuration for Hetzner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Match NixOS 25.05 ISO
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Common pkgs function for all systems
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
            "surrealdb"
          ];
        };
      };
    in
    {
      # NixOS configuration for Hetzner Cloud
      nixosConfigurations = {
        hetzner-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
          ];
        };
      };

      # Project-specific outputs (devShell and packages)
      ${flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = mkPkgs system;
        in
        {
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [
              rustc
              cargo
              rustfmt
              clippy
              cargo-watch
              openssl
              surrealdb
              jq
            ] ++ (if system == "x86_64-darwin" || system == "aarch64-darwin" then [ darwin.apple_sdk.frameworks.Security darwin.apple_sdk.frameworks.SystemConfiguration ] else []);
            shellHook = ''
              export CARGO_HOME=$HOME/.cargo
              export PATH=$CARGO_HOME/bin:$PATH
              echo "SurrealDB CLI available at $(which surreal)"
              echo "Run 'surreal start --user root --pass root --bind 0.0.0.0:8000' to start SurrealDB server"
            '';
          };
          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = "visitflow-backend";
            version = "0.1.0";
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [ openssl ] ++ (if system == "x86_64-darwin" || system == "aarch64-darwin" then [ darwin.apple_sdk.frameworks.Security darwin.apple_sdk.frameworks.SystemConfiguration ] else []);
          };
        })}
    ;
}
