output "pools" {
  description = "Per-pool VM names and IPs"
  value       = { for k, m in module.vms : k => m.vms }
}

output "ips_by_pool" {
  description = "Per-pool list of VM IPs"
  value       = { for k, m in module.vms : k => m.ips }
}

output "all_ips" {
  description = "Flat list of all VM IPs across pools"
  value       = flatten([for m in module.vms : m.ips])
}
