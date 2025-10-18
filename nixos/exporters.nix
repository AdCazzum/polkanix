{inputs, ...}: let
  # Base modules shared by all images
  baseModules = [
    inputs.dotnix.nixosModules.polkadot-validator
    inputs.dotnix.nixosModules.selinux
    inputs.srvos.nixosModules.server
    ./_base.nix
    {
      environment.systemPackages = [
        inputs.polkadot-nix.packages.x86_64-linux.polkadot
      ];
    }
  ];

  mkImage = format: extraModules: inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    inherit format;
    modules = baseModules ++ extraModules;
  };

  cloudImageModule = {lib, ...}: {
    security.sudo.execWheelOnly = lib.mkForce false;
  };

  noBootloaderModule = {lib, ...}: {
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  };

  virtualboxModule = {
    virtualbox.params.diskSize = 16384; # 16GB instead of default 8GB
    virtualbox.params.memorySize = 2048; # 2GB RAM for the final VM
    virtualbox.memorySize = 4096; # 4GB RAM for the build VM
  };

  lxcModule = {lib, ...}: {
    networking.useHostResolvConf = lib.mkForce false;
    services.resolved.enable = lib.mkForce true;
  };
in {
  flake = {
    packages.x86_64-linux = {
      qcow2 = mkImage "qcow" [];

      ami = mkImage "amazon" [
        inputs.srvos.nixosModules.hardware-amazon
        cloudImageModule
        noBootloaderModule
      ];

      gce = mkImage "gce" [
        cloudImageModule
        noBootloaderModule
      ];

      azure = mkImage "azure" [
        cloudImageModule
        noBootloaderModule
      ];

      do = mkImage "do" [
        cloudImageModule
        noBootloaderModule
      ];

      linode = mkImage "linode" [
        cloudImageModule
        noBootloaderModule
      ];

      oracle = mkImage "raw-efi" [
        cloudImageModule
      ];

      vmware = mkImage "vmware" [];
      proxmox = mkImage "proxmox" [
        noBootloaderModule
      ];
      hyperv = mkImage "hyperv" [];

      lxc = mkImage "lxc" [
        lxcModule
        noBootloaderModule
      ];
    };
  };
}
