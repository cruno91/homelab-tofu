resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.ubuntu_image_url

  # `ubuntu_image_url` points at Ubuntu's ".../current/" build, which moves. With the
  # default overwrite = true, the provider compares the stored file's size with the
  # URL's Content-Length on EVERY plan, sees drift whenever Canonical publishes a new
  # build, and replaces the file. Every VM disk references it by file_id, so that
  # replacement cascades into destroying and recreating all three mgmt VMs (caught by
  # `tofu plan` on 2026-10-18: "4 to add, 4 to destroy"). The image only matters
  # when a VM is first created, so never re-check it.
  overwrite = false
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

  # Start with the Proxmox host. The module default is false, which left the whole
  # mgmt plane down after any host reboot until someone ran `qm start` (found
  # 2026-10-18 while planning the platform upgrade).
  on_boot = true

  username = var.vm_username
  password = var.vm_password
  # trimspace: file() keeps the key file's trailing newline, Proxmox stores the key
  # without it, and the mismatch showed up as a perpetual cloud-init diff.
  ssh_public_key = trimspace(file(var.local_ssh_public_key))
}
