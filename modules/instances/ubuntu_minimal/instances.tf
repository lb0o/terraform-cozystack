locals {
  node_name     = var.ubuntu_minimal.node_name
  storage_device = var.ubuntu_minimal.storage_device
}


locals {
  vm_ids = { for i in range(var.ubuntu_minimal.vm_count) : tostring(i) => "${var.ubuntu_minimal.vm_hostname}${i}" }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count = var.ubuntu_minimal.vm_count

  name      = local.vm_ids[count.index]
  node_name = local.node_name
  on_boot   = var.ubuntu_minimal.on_boot
  tags      = var.ubuntu_minimal.tags
  vm_id     = "${format("${var.ubuntu_minimal.vm_id_prefix}%02s", count.index)}"

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  machine = "q35"

  cpu {
    cores        = var.ubuntu_minimal.cpu_cores
    hotplugged   = 0
    limit        = 0
    numa         = false
    sockets      = 1
    units        = 1024
  }

  dynamic "disk" {
    for_each = var.ubuntu_minimal.additional_disks
    content {
      interface    = "virtio${1 + disk.key}"
      iothread     = true
      datastore_id = var.ubuntu_minimal.storage_ssd
      size         = disk.value.size
      discard      = "ignore"
      file_format  = "raw"
    }
  }
  

  memory {
    dedicated = var.ubuntu_minimal.vm_memory
  }

  disk {
    datastore_id = var.ubuntu_minimal.storage_ssd
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image_gpu.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.ubuntu_minimal.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ubuntu_minimal.network_ipconfig
        gateway = var.ubuntu_minimal.network_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[count.index].id
  }

  network_device {
    bridge   = var.ubuntu_minimal.external_bridge
    firewall = var.ubuntu_minimal.firewall
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Download an online image to use
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_gpu" {
  content_type = "iso"
  datastore_id = var.ubuntu_minimal.storage_nas
  node_name    = var.ubuntu_minimal.node_name
  file_name    = var.ubuntu_minimal.url_file_name
  url          = var.ubuntu_minimal.url_image
}
