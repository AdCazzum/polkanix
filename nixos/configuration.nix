{inputs, ...}: {
  flake.nixosConfigurations.polkadot-validator = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({...
      }: {
        imports = [
          inputs.dotnix.nixosModules.polkadot-validator
          inputs.dotnix.nixosModules.selinux
          inputs.disko.nixosModules.default
          inputs.srvos.nixosModules.server
          inputs.srvos.nixosModules.hardware-hetzner-cloud
          ./_disko.nix
        ];

        # SSH access
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        users.users.root.openssh.authorizedKeys.keys = [
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm9Sl/I+5G4g4f6iE4oCUJteP58v+wMIew9ZuLB+Gea"
        ];

        # Polkadot validator configuration
        dotnix.polkadot-validator = {
          enable = true;
          name = "ETHRome";
          chain = "paseo";
          extraArgs = [
            "--rpc-external"
            "--rpc-cors=all"
            "--rpc-methods=unsafe"  # Needed for author_rotateKeys
            "--sync=warp"
          ];
        };

        environment.systemPackages = [
          inputs.polkadot-nix.packages.x86_64-linux.polkadot
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Basic system configuration
        networking.hostName = "polkadot-validator";
        system.stateVersion = "24.11";
      })
    ];
  };
}
