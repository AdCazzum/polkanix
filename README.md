# Porcadot - Polkadot Validator on Hetzner Cloud

NixOS configuration for a Polkadot validator on the Paseo testnet, deployed on Hetzner Cloud.

## Prerequisites

- Hetzner Cloud account
- Hetzner Cloud API token
- OpenTofu (or Terraform) installed
- Nix with flakes enabled

## Deployment

### 1. Configure environment variables

Copy the example file and configure your Hetzner token:

```bash
cp .envrc.example .envrc
```

Edit `.envrc` and insert your Hetzner Cloud token:

```bash
export TF_VAR_hcloud_token="your-hetzner-cloud-token-here"
```

Activate the environment:

```bash
direnv allow
```

### 2. Deploy infrastructure

Run the deployment with OpenTofu:

```bash
tofu init
tofu apply
```

This will create:
- Hetzner Cloud server (cpx42: 8 vCPU, 16GB RAM)
- SSH keys configured
- NixOS system with Polkadot validator

### 3. Configure the validator

After deployment, connect to the server:

```bash
ssh root@$(tofu output -raw server_ipv4)
```

#### 3.1 Generate and configure the node key

Generate a new node key:

```bash
polkadot key generate-node-key
```

This command will return two values:
- **Peer ID**: starts with `12D3KooW...` (public node identifier)
- **Node key**: hexadecimal string (this is the private key to save)

Save the node key to the configuration file:

```bash
# Create directory if it doesn't exist
mkdir -p /var/secrets

# Save the node key (replace with the one generated above)
echo "YOUR_HEXADECIMAL_NODE_KEY" > /var/secrets/polkadot-validator.node_key

# Set correct permissions
chmod 600 /var/secrets/polkadot-validator.node_key
```

**The validator will start automatically** thanks to the orchestrator monitoring the key file.

#### 3.2 Verify synchronization

Check that the validator is syncing:

```bash
journalctl -u polkadot-validator -f
```

You'll see messages like:
- `⚙️ State sync, Downloading state...` - downloading state
- `⏩ Block history...` - downloading block history
- `🏆 Imported #XXXXXX` - **synced and operational!**

Synchronization with warp sync takes about 15-30 minutes.

### 4. Become an active validator

Once synced, you can configure the validator to participate in consensus.

#### 4.1 Generate session keys

```bash
polkadot-validator --rotate-keys
```

This command will return a hexadecimal string (your public session keys). **Save it**, you'll need it in the next step.

#### 4.2 Configure the validator on Polkadot.js

1. Go to https://polkadot.js.org/apps/?rpc=wss://paseo.rpc.amforc.com
2. Request PAS tokens from the Paseo faucet
3. Go to **Network → Staking → Account actions**
4. Click **+ Validator**
5. Bond your PAS tokens
6. Click **Set Session Keys** and paste the keys generated in step 4.1
7. Confirm the transaction

#### 4.3 Wait for election

Not all validators are elected immediately. You need to wait for the next "era" (validation period) to be included in the active set.

You can monitor the status on Polkadot.js in **Network → Staking → Waiting**.

## Useful commands

### Validator management

```bash
# Check service status
systemctl status polkadot-validator

# View logs in real-time
journalctl -u polkadot-validator -f

# Restart the validator
systemctl restart polkadot-validator

# Stop the validator
systemctl stop polkadot-validator
```

### Key management

```bash
# Set a new node key
polkadot-validator --set-node-key

# Remove the node key (stops the validator)
polkadot-validator --unset-node-key

# Generate new session keys
polkadot-validator --rotate-keys
```

### Backup and snapshots

```bash
# Create a keystore backup
polkadot-validator --backup-keystore

# Create a database snapshot
polkadot-validator --snapshot

# Restore from snapshot
polkadot-validator --restore http://snapshot.stakeworld.io/paritydb-paseo.lz4
```

### Monitoring

```bash
# Server information
tofu output

# Quick SSH command
ssh root@$(tofu output -raw server_ipv4)

# Disk space
df -h

# Active processes
ps aux | grep polkadot
```

## Building Images

This project can generate NixOS images for various platforms and cloud providers.

### Available Images

#### Cloud Providers
- **Amazon EC2** (`ami`) - Amazon Machine Image with AWS hardware optimizations
- **Google Cloud** (`gce`) - Google Compute Engine image
- **Microsoft Azure** (`azure`) - Azure-compatible VHD
- **DigitalOcean** (`do`) - DigitalOcean droplet image
- **Linode** (`linode`) - Linode-compatible image
- **Oracle Cloud** (`oracle`) - Oracle Cloud Infrastructure image

#### Virtualization Platforms
- **QEMU/KVM** (`qcow2`) - QCOW2 disk image for KVM/libvirt
- **Proxmox** (`proxmox`) - Proxmox VE compatible image (GRUB bootloader)
- **VMware** (`vmware`) - VMware ESXi/Workstation image
- **VirtualBox** (`virtualbox`) - VirtualBox OVA
- **Hyper-V** (`hyperv`) - Microsoft Hyper-V image

#### Containers
- **LXC** (`lxc`) - Linux Container image

### Building an Image

To build any image, use:

```bash
nix build .#<image-name>
```

Examples:

```bash
# Build QCOW2 image for KVM
nix build .#qcow2

# Build Proxmox image
nix build .#proxmox

# Build Amazon EC2 AMI
nix build .#ami

# Build DigitalOcean image
nix build .#do
```

The built image will be available in `./result/`.

### Image Configuration

All images include:
- Polkadot validator (Paseo testnet)
- SSH access with pre-configured key
- SELinux enabled
- srvos security hardening
