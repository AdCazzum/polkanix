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

  # Generate image with optional extra modules
  mkImage = format: extraModules: inputs.nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    inherit format;
    modules = baseModules ++ extraModules;
  };

  # Cloud images need to disable sudo.execWheelOnly
  cloudImageModule = {lib, ...}: {
    security.sudo.execWheelOnly = lib.mkForce false;
  };

  # Some formats configure their own bootloader
  noBootloaderModule = {lib, ...}: {
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  };

  # LXC containers need special network configuration
  lxcModule = {lib, ...}: {
    networking.useHostResolvConf = lib.mkForce false;
    services.resolved.enable = lib.mkForce true;
  };
in {
  flake = {
    packages.x86_64-linux = {
      # QEMU/KVM
      qcow2 = mkImage "qcow" [];

      # Cloud providers
      ami = mkImage "amazon" [
        inputs.srvos.nixosModules.hardware-amazon
        cloudImageModule
      ];

      gce = mkImage "gce" [
        cloudImageModule
      ];

      azure = mkImage "azure" [
        cloudImageModule
      ];

      do = mkImage "do" [
        cloudImageModule
      ];

      linode = mkImage "linode" [
        cloudImageModule
        noBootloaderModule
      ];

      # Oracle Cloud Infrastructure - using raw-efi format
      oracle = mkImage "raw-efi" [
        cloudImageModule
      ];

      # Virtualization
      vmware = mkImage "vmware" [];
      virtualbox = mkImage "virtualbox" [];
      proxmox = mkImage "proxmox" [
        noBootloaderModule
      ];
      hyperv = mkImage "hyperv" [];

      # Container
      lxc = mkImage "lxc" [
        lxcModule
        noBootloaderModule
      ];
    };
  };
}
