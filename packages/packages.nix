{
  perSystem = {pkgs, ...}: {
    packages.cargo-contract = pkgs.callPackage ./cargo-contract/_package.nix {};
  };
}
