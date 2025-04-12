#Load local SSH key for injecting into VMs
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ubuntu_minimal.local_ssh_public_key_path)
}

#Custom cloud-init to add qemu-guest-agent and SSH key
resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = local.vm_ids

  content_type = "snippets"
  datastore_id = var.ubuntu_minimal.storage_nas
  node_name    = local.node_name

  source_raw {
    data = <<EOF
#cloud-config
fqdn: ${each.value}
users:
  - name: ${var.ubuntu_minimal.os_username}
    passwd: ${var.ubuntu_minimal.os_password}
    lock-passwd: false
    ssh_pwauth: True
    chpasswd: { expire: False }
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${trimspace(data.local_file.ssh_public_key.content)}
    sudo: ALL=(ALL) NOPASSWD:ALL
runcmd:
  - apt update
  - apt install -y qemu-guest-agent net-tools
  - timedatectl set-timezone Europe/Paris
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "done" > /tmp/cloud-config.done
EOF

    file_name = "${each.value}_cloud-config.yaml"
  }
}
