output "vm_ipv4_addresses" {
  value = {
    for i, vm in proxmox_virtual_environment_vm.ubuntu_vm : "vm_${i}_ipv4_address" => vm.ipv4_addresses[1][0]
  }
}

output "vm_ip_addresses" {
  value = try(proxmox_virtual_environment_vm.ubuntu_vm[*], null)
}

output "vm_id" {
  value = try(proxmox_virtual_environment_vm.ubuntu_vm[*].vm_id, null)
}

output "vm_name" {
  value = try(proxmox_virtual_environment_vm.ubuntu_vm[*].name, null)
}
