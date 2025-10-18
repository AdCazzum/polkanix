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

  # VirtualBox needs more resources for building
  virtualboxModule = {
    virtualbox.params.diskSize = 16384; # 16GB instead of default 8GB
    virtualbox.params.memorySize = 2048; # 2GB RAM for the final VM
    virtualbox.vmBootMemorySize = 4096; # 4GB RAM for the build process
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

      # Oracle Cloud Infrastructure - using raw-efi format
      oracle = mkImage "raw-efi" [
        cloudImageModule
      ];

      # Virtualization
      vmware = mkImage "vmware" [];
      virtualbox = mkImage "virtualbox" [
        noBootloaderModule
        virtualboxModule
      ];
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
