{inputs, ...}: {
  imports = [inputs.make-shell.flakeModules.default];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    make-shells.default = {
      packages = with pkgs; [
        config.packages.cargo-contract
        config.packages.rustc-with-src
        cargo
        rust-analyzer
        pkg-config
        openssl
        cmake
        clippy
        lld
      ];

      env."RUST_SRC_PATH" = pkgs.rustPlatform.rustLibSrc;
    };
  };
}
