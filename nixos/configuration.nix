{inputs, ...}: {
  flake.nixosConfigurations.polkadot-validator = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.dotnix.nixosModules.polkadot-validator
      inputs.dotnix.nixosModules.selinux
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud
      inputs.disko.nixosModules.default
      ./_base.nix
      ./_disko.nix
      ./_grafana.nix
      ./_nginx.nix
      {
        environment.systemPackages = [
          inputs.polkadot-nix.packages.x86_64-linux.polkadot
        ];
      }
    ];
  };
}
