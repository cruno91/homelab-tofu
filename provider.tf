terraform {
    required_providers {
        proxmox =  {
        source = "bpg/proxmox"
        version = ">= 0.109.0"
        }
    }
}
provider "proxmox" {
    insecure = true  # Warning TLS cert of proxmox webui must be valid (Let's Encrypt)
    endpoint  = "https://${var.proxmox_server_ip}:8006/api2/json"
    api_token = format("%s!%s=%s", var.proxmox_user, var.proxmox_api_key_name, var.proxmox_api_key_secret)
    ssh {
        agent    = true
        username = "root"
        private_key = file(var.local_ssh_private_key)
    }
}
