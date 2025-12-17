{
  description = "Build static bpftrace for Android (aarch64)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Cách này sẽ tải source ổn định từ Nixpkgs để build (an toàn nhất)
        packages.default = pkgs.pkgsStatic.bpftrace.overrideAttrs (old: {
          doCheck = false;
          postInstall = ''
            ${old.postInstall or ""}
            $STRIP $out/bin/bpftrace
          '';
        });
      }
    );
}
