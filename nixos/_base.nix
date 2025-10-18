{lib, ...}: {
  # SSH access
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm9Sl/I+5G4g4f6iE4oCUJteP58v+wMIew9ZuLB+Gea"
  ];

  dotnix.polkadot-validator = {
    enable = true;
    name = "ETHRome";
    chain = "paseo";
    extraArgs = [
      "--rpc-external"
      "--rpc-cors=all"
      "--rpc-methods=unsafe" # Needed for author_rotateKeys
      "--sync=warp"
    ];
  };

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.hostName = "polkadot-validator";
  system.stateVersion = "24.11";
}
