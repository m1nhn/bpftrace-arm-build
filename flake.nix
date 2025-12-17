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
        # pkgsStatic sẽ tự động chuyển toàn bộ toolchain sang Musl và Static linking
        packages.default = pkgs.pkgsStatic.bpftrace.overrideAttrs (old: {
          # Tắt test để build nhanh hơn
          doCheck = false;
          
          # Strip debug symbols để file nhẹ hơn
          postInstall = ''
            ${old.postInstall or ""}
            $STRIP $out/bin/bpftrace
          '';
        });
      }
    );
}
