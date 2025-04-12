resource "proxmox_virtual_environment_cluster_firewall" "firewall_cluster_nocilo" {
  enabled = true
  ebtables = false
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  
  log_ratelimit {
    enabled = false
    burst   = 10
    rate    = "5/second"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  for_each = { for idx, vm in proxmox_virtual_environment_vm.ubuntu_vm : idx => vm.vm_id }

  vm_id     = each.value
  node_name = var.ubuntu_minimal.node_name

  dynamic "rule" {
    for_each = toset(var.ubuntu_minimal.tags)  # Convert the list to a set for iteration

    content {
      security_group = rule.value  # Directly use the tag as a security group identifier
      comment        = "Allow ${rule.key} traffic from security group"
      iface          = "net0"
    }
  }
}
