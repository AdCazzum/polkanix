{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    make-shells.default = {
      packages = with pkgs; [
        opentofu
        inputs'.polkadot-nix.packages.polkadot
      ];
    };
  };
}
