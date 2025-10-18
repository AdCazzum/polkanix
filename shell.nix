{
  perSystem = {
    pkgs,
    ...
  }: {
    make-shells.default = {
      packages = with pkgs; [
        opentofu
      ];
    };
  };
}
