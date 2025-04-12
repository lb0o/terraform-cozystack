output "bridge_name" {
  description = "Name of the created bridge interface"
  value       = proxmox_virtual_environment_network_linux_bridge.cozystack_bridge.name
}

output "bridge_cidr" {
  description = "CIDR of the bridge network"
  value       = proxmox_virtual_environment_network_linux_bridge.cozystack_bridge.address
} 