# homelab-tofu

OpenTofu configuration that provisions a small RKE2-shaped cluster (servers + agents) on a Proxmox host, using the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider.

This is a Terraform/OpenTofu **root module**. The actual VM resource is wrapped in a small child module at `modules/proxmox-vm/` and is driven from a `node_pools` map in `terraform.tfvars`.

## Prerequisites

- A Proxmox VE host reachable on the network.
- A Proxmox API token. Create one in *Datacenter → Permissions → API Tokens*; uncheck "Privilege Separation" or grant the token sufficient permissions to create VMs and download files.
- An SSH key pair on the machine running `tofu`.
- [OpenTofu](https://opentofu.org/) (or Terraform) installed locally.

## Quick start

```sh
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars     # fill in proxmox_server_ip, api token, node_name

tofu init
tofu plan
tofu apply
```

After apply, IPs are available via:

```sh
tofu output pools          # { "rke2-server" = [ { name = "rke2-server-1", ip = "10.0.3.41" }, ... ], ... }
tofu output ips_by_pool    # { "rke2-server" = ["10.0.3.41", ...], ... }
tofu output all_ips        # ["10.0.3.40", "10.0.3.41", ...]
```

## Configuration

All variables are defined in `variables.tf` with defaults; the table below covers the ones you'll typically touch. See the file for the full list (datastore IDs, network bridge, machine type, BIOS, image URL).

| Variable | Required | Default | Notes |
| --- | --- | --- | --- |
| `proxmox_server_ip` | yes | – | Proxmox host IP. |
| `proxmox_user` | no | `root@pam` | Username with realm. |
| `proxmox_api_key_name` | yes | – | Token name. |
| `proxmox_api_key_secret` | yes | – | Token secret (sensitive). |
| `node_name` | yes | – | Proxmox node name. |
| `default_network` | no | `10.0.3` | First three octets of the VM network. |
| `vm_username` | no | `ubuntu` | Cloud-init username. |
| `vm_password` | no | `ubuntu` | Cloud-init password (sensitive). |
| `local_ssh_public_key` | no | `~/.ssh/id_rsa.pub` | Injected into each VM. |
| `local_ssh_private_key` | no | `~/.ssh/id_rsa` | Used by the provider to SSH to Proxmox. |
| `node_pools` | no | three RKE2 pools | See below. |

### `node_pools`

A map keyed by pool name. Each VM is named `<pool>-<index>` and gets IP `<default_network>.<ip_start + offset>/24`.

```hcl
node_pools = {
  "rke2-server" = {
    count       = 3
    cpu         = 4
    memory      = 16384   # MB
    ip_start    = 41      # produces .41, .42, .43
    disk_gb     = 60      # optional, defaults to 60
    description = "RKE2 server"
  }
}
```

To add a new pool — say, a worker pool — append an entry:

```hcl
"worker" = {
  count    = 2
  cpu      = 8
  memory   = 32768
  ip_start = 50
}
```

IP ranges across pools are not validated; make sure `ip_start` + `count` don't overlap.

## Migrating from the pre-module layout

If you already applied an earlier version of this repo, the resource addresses have changed:

| Old address | New address |
| --- | --- |
| `proxmox_virtual_environment_vm.rke2_server_ubuntu_vm[0..2]` | `module.vms["rke2-server"].proxmox_virtual_environment_vm.node[0..2]` |
| `proxmox_virtual_environment_vm.rke2_agent_ubuntu_vm[0]` | `module.vms["rke2-agent"].proxmox_virtual_environment_vm.node[0]` |

To migrate state without destroying VMs:

```sh
tofu state mv 'proxmox_virtual_environment_vm.rke2_load_balancer[0]' 'module.vms["ex-lb"].proxmox_virtual_environment_vm.node[0]'

for i in 0 1 2; do
  tofu state mv "proxmox_virtual_environment_vm.rke2_server_ubuntu_vm[$i]" "module.vms[\"rke2-server\"].proxmox_virtual_environment_vm.node[$i]"
done

tofu state mv 'proxmox_virtual_environment_vm.rke2_agent_ubuntu_vm[0]' 'module.vms["rke2-agent"].proxmox_virtual_environment_vm.node[0]'
```

Also note that VM names change: the LB goes from `ex-lb` to `ex-lb-1`. The provider may want to rename it in place on the next apply.

## Layout

```
.
├── main.tf                  # download_file + module "vms" for_each over node_pools
├── variables.tf             # all input variables
├── outputs.tf               # per-pool and flat IP outputs
├── provider.tf              # bpg/proxmox provider config
├── terraform.tfvars.example # template; copy to terraform.tfvars
└── modules/
    └── proxmox-vm/          # child module, one pool of VMs
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
