resource "proxmox_virtual_environment_container" "opnsense_container" {
  description = "Managed by Terraform"

  node_name = var.opnsense.node_name
  vm_id     = var.opnsense.vm_id_prefix

  initialization {
    hostname = var.opnsense.initialization.hostname

    ip_config {
      ipv4 {
        address = var.opnsense.initialization.ip_config.ipv4.address
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.opnsense_container_key.public_key_openssh)
      ]
      password = random_password.opnsense_container_password.result
    }
  }

  network_interface {
    name = var.opnsense.network_interface.name
  }

  disk {
    datastore_id = var.opnsense.disk.datastore_id
    size         = var.opnsense.disk.size
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.opnsense_template.id
    type             = var.opnsense.operating_system.type
  }

  mount_point {
    volume = var.opnsense.mount_point.volume
    size   = var.opnsense.mount_point.size
    path   = var.opnsense.mount_point.path
  }

  startup {
    order      = var.opnsense.startup.order
    up_delay   = var.opnsense.startup.up_delay
    down_delay = var.opnsense.startup.down_delay
  }
}

resource "proxmox_virtual_environment_download_file" "opnsense_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.opnsense.node_name
  url          = var.opnsense.image_url
}

resource "random_password" "opnsense_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "opnsense_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}