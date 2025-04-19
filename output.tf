output "talos_config" {
    description = "Talos configuration file"
    value       = module.talos.talos_config
    sensitive   = true
}

output "kubeconfig" {
    description = "Kubeconfig file"
    value       = module.talos.kubeconfig
    sensitive   = true
}

output "network_machine_password" {
  value     = random_password.container_password.result
  sensitive = true
}

output "network_machine_private_key" {
  value     = tls_private_key.network_machine_ssh_key.private_key_pem
  sensitive = true
}

output "network_machine_public_key" {
  value = tls_private_key.network_machine_ssh_key.public_key_openssh
}

output "dev_machine_private_key" {
  value     = tls_private_key.dev_machine_ssh_key.private_key_pem
  sensitive = true
}

output "dev_machine_public_key" {
  value = tls_private_key.dev_machine_ssh_key.public_key_openssh
}

output "alias_ssh_cozy_network_machine" {
  value = "alias ssh_cozy_network_machine='ssh -F $(pwd)/tmp_config network-machine'"
}

output "alias_ssh_cozy_dev_machine" {
  value = "alias ssh_cozy_dev_machine='ssh -F $(pwd)/tmp_config dev-machine'"
}