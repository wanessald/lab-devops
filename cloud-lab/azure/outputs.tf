output "swarm_nodes_public_ips" {
  description = "IPs públicos das VMs do cluster Swarm"
  value = {
    for name, pip in azurerm_public_ip.lab_pip :
    name => pip.ip_address
  }
}

output "swarm_nodes_private_ips" {
  description = "IPs privados das VMs do cluster Swarm"
  value = {
    for name, nic in azurerm_network_interface.lab_nic :
    name => nic.ip_configuration[0].private_ip_address
  }
}
