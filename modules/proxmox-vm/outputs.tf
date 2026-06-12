output "vms" {
  description = "List of VMs in this pool with name and IP"
  value = [
    for i, vm in proxmox_virtual_environment_vm.node : {
      name = vm.name
      ip   = "${var.network_prefix}.${var.ip_start + i}"
    }
  ]
}

output "ips" {
  description = "List of VM IPs in this pool"
  value       = [for i in range(var.instance_count) : "${var.network_prefix}.${var.ip_start + i}"]
}
