variable "proxmox_server_ip" {
  description = "IP address of the Proxmox server"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username with realm (e.g. root@pam)"
  type        = string
  default     = "root@pam"
}

variable "proxmox_api_key_name" {
  description = "Name of the API token for Proxmox"
  type        = string
}

variable "proxmox_api_key_secret" {
  description = "Secret of the API token for Proxmox"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Name of the Proxmox node to run VMs on"
  type        = string
}

variable "default_network" {
  description = "First three octets of your VM network (e.g. 10.0.3)"
  type        = string
  default     = "10.0.3"
}

variable "local_ssh_public_key" {
  description = "Path to local SSH public key injected into VMs"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "local_ssh_private_key" {
  description = "Path to local SSH private key used to talk to Proxmox"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "vm_username" {
  description = "Default cloud-init username for VMs"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "Default cloud-init password for VMs"
  type        = string
  default     = "ubuntu"
  sensitive   = true
}

variable "node_pools" {
  description = <<-EOT
    Map of VM pools to create. Pool key is used as the VM name prefix
    (e.g. "server" -> server-1, server-2). Each VM in a pool gets an IP
    of <default_network>.<ip_start + index>/24.
  EOT
  type = map(object({
    count       = number
    cpu         = number
    memory      = number
    ip_start    = number
    disk_gb     = optional(number, 60)
    description = optional(string, "")
  }))
  default = {
    "rke2-server" = {
      count       = 3
      cpu         = 4
      memory      = 16384
      ip_start    = 41
      description = "RKE2 server instantiated by OpenTofu"
    }
    # "rke2-agent" = {
    #   count       = 1
    #   cpu         = 4
    #   memory      = 16384
    #   ip_start    = 44
    #   description = "RKE2 agent instantiated by OpenTofu"
    # }
  }
}

variable "ubuntu_image_url" {
  description = "URL of the Ubuntu cloud image to download"
  type        = string
  default     = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
}

variable "datastore_id" {
  description = "Proxmox datastore for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "image_datastore_id" {
  description = "Proxmox datastore where the downloaded cloud image is stored"
  type        = string
  default     = "local"
}

variable "network_bridge" {
  description = "Proxmox network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "machine_type" {
  description = "QEMU machine type for VMs"
  type        = string
  default     = "q35"
}

variable "bios" {
  description = "VM BIOS"
  type        = string
  default     = "ovmf"
}
