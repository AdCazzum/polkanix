{inputs, ...}: {
  imports = [
    inputs.make-shell.flakeModules.default
  ];
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    make-shells.default = {
      packages = with pkgs; [
        opentofu
        jq
        inputs'.polkadot-nix.packages.polkadot
      ];
    };
  };
}
