locals {
  # Extract token and endpoint from the provider configuration
  proxmox_endpoint = replace(var.endpoint, "/api2/json", "")
}

# Create the network bridge using the Proxmox provider
resource "proxmox_virtual_environment_network_linux_bridge" "cozystack_bridge" {
  node_name = var.node_name
  name      = var.bridge_name
  
  address   = var.bridge_cidr
  gateway   = null
  
  ports    = var.bridge_ports == "none" ? [] : [var.bridge_ports]
  vlan_aware = var.bridge_vlan_aware
  
  autostart = var.autostart
  comment  = var.comments
} 