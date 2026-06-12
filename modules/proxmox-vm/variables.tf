variable "name_prefix" {
  description = "Prefix for VM names; instances are suffixed with -1, -2, ..."
  type        = string
}

variable "instance_count" {
  description = "Number of VMs to create in this pool"
  type        = number
}

variable "description" {
  description = "Free-text description applied to each VM"
  type        = string
  default     = ""
}

variable "proxmox_node_name" {
  description = "Name of the Proxmox node to run VMs on"
  type        = string
}

variable "network_prefix" {
  description = "First three octets of the VM network (e.g. 10.0.3)"
  type        = string
}

variable "ip_start" {
  description = "Last octet of the first VM; subsequent VMs get ip_start+1, ip_start+2, ..."
  type        = number
}

variable "cpu" {
  description = "vCPU cores per VM"
  type        = number
}

variable "memory" {
  description = "Memory per VM in MB"
  type        = number
}

variable "disk_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 60
}

variable "datastore_id" {
  description = "Proxmox datastore for VM disks"
  type        = string
}

variable "image_file_id" {
  description = "ID of the cloud image to clone (from proxmox_virtual_environment_download_file)"
  type        = string
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
}

variable "machine_type" {
  description = "QEMU machine type"
  type        = string
}

variable "bios" {
  description = "VM BIOS"
  type        = string
}

variable "on_boot" {
  description = "Whether VMs start automatically when the Proxmox host boots"
  type        = bool
  default     = false
}

variable "username" {
  description = "Cloud-init username"
  type        = string
}

variable "password" {
  description = "Cloud-init password"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key contents (not a path)"
  type        = string
}
