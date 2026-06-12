resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.ubuntu_image_url
}

module "vms" {
  source   = "./modules/proxmox-vm"
  for_each = var.node_pools

  name_prefix    = each.key
  instance_count = each.value.count
  description    = each.value.description
  cpu            = each.value.cpu
  memory         = each.value.memory
  ip_start       = each.value.ip_start
  disk_gb        = each.value.disk_gb

  proxmox_node_name = var.node_name
  network_prefix    = var.default_network
  image_file_id     = proxmox_download_file.ubuntu_cloud_image.id

  datastore_id   = var.datastore_id
  network_bridge = var.network_bridge
  machine_type   = var.machine_type
  bios           = var.bios

  username       = var.vm_username
  password       = var.vm_password
  ssh_public_key = file(var.local_ssh_public_key)
}
