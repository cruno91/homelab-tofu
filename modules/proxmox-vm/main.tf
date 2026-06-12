terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.109.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  count = var.instance_count

  name        = "${var.name_prefix}-${count.index + 1}"
  description = var.description
  node_name   = var.proxmox_node_name

  machine       = var.machine_type
  bios          = var.bios
  on_boot       = var.on_boot
  scsi_hardware = "virtio-scsi-single"

  initialization {
    ip_config {
      ipv4 {
        address = "${var.network_prefix}.${var.ip_start + count.index}/24"
        gateway = "${var.network_prefix}.1"
      }
    }

    user_account {
      username = var.username
      password = var.password
      keys     = [var.ssh_public_key]
    }
  }

  efi_disk {
    datastore_id = var.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = var.image_file_id
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.disk_gb
    ssd          = true
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  cpu {
    cores = var.cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }
}
