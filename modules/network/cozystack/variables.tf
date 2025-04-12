variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "endpoint" {
  description = "Proxmox API endpoint (e.g., https://proxmox:8006/api2/json)"
  type        = string
}

variable "api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "bridge_name" {
  description = "Name of the bridge interface (e.g., cozy0)"
  type        = string
  default     = "cozy0"
}

variable "bridge_cidr" {
  description = "CIDR for the bridge network (e.g., 10.0.0.1/24)"
  type        = string
  default     = "10.0.0.1/24"
}

variable "bridge_ports" {
  description = "Physical interfaces to use for the bridge (empty for isolated bridge)"
  type        = string
  default     = ""
}

variable "bridge_vlan_aware" {
  description = "Whether the bridge should be VLAN aware"
  type        = bool
  default     = true
}

variable "autostart" {
  description = "Whether to start the bridge on boot"
  type        = bool
  default     = true
}

variable "comments" {
  description = "Comments for the bridge"
  type        = string
  default     = "Created by Cozystack automation"
} 