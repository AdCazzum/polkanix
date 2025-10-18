provider "hcloud" {
  token = var.hcloud_token
}

# Get SSH keys directly from NixOS configuration
data "external" "ssh_keys" {
  program = ["bash", "-c", "nix eval .#nixosConfigurations.polkadot-validator.config.users.users.root.openssh.authorizedKeys.keys --json | jq '{keys: tojson}'"]
}

locals {
  ssh_public_keys = jsondecode(data.external.ssh_keys.result.keys)
}

resource "hcloud_ssh_key" "ssh_public_keys" {
  name       = "hcloud_ssh_key-${each.key}"
  for_each   = { for idx, key in local.ssh_public_keys : tostring(idx) => key }
  public_key = each.value
}

resource "hcloud_server" "polkadot-validator" {
  name        = "polkadot-validator"
  image       = "debian-11" # used only for the initial bootstrapping
  server_type = "cpx42"
  location    = "fsn1"
  ssh_keys    = [for _, v in hcloud_ssh_key.ssh_public_keys : v.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  lifecycle {
    ignore_changes = [
      ssh_keys
    ]
  }
}

module "deploy" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"

  nixos_system_attr      = ".#nixosConfigurations.polkadot-validator.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.polkadot-validator.config.system.build.diskoScript"

  target_host = hcloud_server.polkadot-validator.ipv4_address
  instance_id = hcloud_server.polkadot-validator.id
}

output "server_ipv4" {
  value       = hcloud_server.polkadot-validator.ipv4_address
  description = "IPv4 address of the server"
}

output "server_ipv6" {
  value       = hcloud_server.polkadot-validator.ipv6_address
  description = "IPv6 address of the server"
}

output "ssh_command" {
  value       = "ssh root@${hcloud_server.polkadot-validator.ipv4_address}"
  description = "SSH command to connect to the server"
}
