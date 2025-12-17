{
  description = "Build static bpftrace for Android (aarch64)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      let
        # FIX: Import nixpkgs với config cho phép gói "không hỗ trợ"
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnsupportedSystem = true; 
          };
        };
      in
      {
        # Sử dụng pkgsStatic để ép build tĩnh (Musl Libc)
        packages.default = pkgs.pkgsStatic.bpftrace.overrideAttrs (old: {
          # Tắt test
          doCheck = false;
          
          # Strip để giảm dung lượng file
          postInstall = ''
            ${old.postInstall or ""}
            $STRIP $out/bin/bpftrace
          '';
        });
      }
    );
}
