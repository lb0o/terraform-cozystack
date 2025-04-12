variable "ubuntu_minimal" {
  description = "Ubuntu Minimal VM configuration"
  type = object({
    node_name = string
    vm_id_prefix = string
    vm_count = number
    vm_hostname = string
    on_boot = bool
    tags = list(string)
    
    # OS credentials
    os_username = string
    os_password = string
    
    # Network configuration
    network_ipconfig = string
    network_gateway = string
    external_bridge = string
    firewall = bool
    
    # VM resources
    cpu_cores = number
    vm_memory = number
    disk_size = number
    
    # Storage configuration
    storage_device = string
    storage_nas = string
    storage_ssd = string
    
    # SSH configuration
    local_ssh_public_key_path = string
    
    # Additional disks
    additional_disks = list(object({
      storage = string
      size = number
    }))
    
    # Image configuration
    url_image = string
    url_file_name = string
  })
  
  default = {
    node_name = "pve"
    vm_id_prefix = "1234"
    vm_count = 1
    vm_hostname = "cozystack"
    on_boot = true
    tags = ["terraform", "cozystack"]
    
    # OS credentials
    os_username = ""
    os_password = ""
    
    # Network configuration
    network_ipconfig = "dhcp"
    network_gateway = ""
    external_bridge = ""
    firewall = true
    
    # VM resources
    cpu_cores = 1
    vm_memory = 2048
    disk_size = 20
    
    # Storage configuration
    storage_device = ""
    storage_nas = ""
    storage_ssd = "nvme"
    
    # SSH configuration
    local_ssh_public_key_path = ""
    
    # Additional disks
    additional_disks = []
    
    # Image configuration
    url_image = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    url_file_name = "jammy-server-cloudimg-amd64.img"
  }
}