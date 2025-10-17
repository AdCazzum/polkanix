{
  perSystem = {pkgs, ...}: {
    packages = {
      cargo-contract = pkgs.callPackage ./cargo-contract/_package.nix {};
      rustc-with-src = pkgs.callPackage ./rustc-with-src/_package.nix {};
    };
  };
}
