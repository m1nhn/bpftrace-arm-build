{
  description = "Build static bpftrace for Android (aarch64)";

  inputs = {
    # Dùng nhánh unstable để có package mới nhất
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      let
        # 1. Cấu hình Nixpkgs để chấp nhận các gói "unsupported" trên ARM64
        # Đây là chìa khóa để fix lỗi 'elfutils' bạn gặp phải
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnsupportedSystem = true;
          };
        };

        # 2. Sử dụng bộ thư viện Static (tự động dùng Musl Libc)
        staticPkgs = pkgs.pkgsStatic;

      in
      {
        packages.default = staticPkgs.bpftrace.overrideAttrs (oldAttrs: {
          name = "bpftrace-android-static";
          
          # Lấy source code từ chính thư mục hiện tại (git checkout của bạn)
          src = self;

          # Ép CMake build tĩnh hoàn toàn
          cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
            "-DCMAKE_BUILD_TYPE=Release"
            "-DSTATIC_LINKING=ON"
            "-DVENDOR_GTEST=OFF"  # Tắt test
            "-DBUILD_TESTING=OFF" # Tắt test system
          ];

          # Build dependencies cần thiết (Nix sẽ tự lo việc kéo bản static)
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
            staticPkgs.pkg-config
            staticPkgs.cmake
            staticPkgs.ninja
          ];

          # Tắt check để build nhanh hơn
          doCheck = false;

          # Sau khi build xong, strip bỏ debug symbols để file nhẹ (~40MB -> ~10MB)
          postInstall = ''
            ${oldAttrs.postInstall or ""}
            echo "Stripping binary..."
            $STRIP $out/bin/bpftrace
          '';
        });
      }
    );
}
