output "swarm_nodes_public_ips" {
  description = "IPs públicos das VMs do cluster Swarm"
  value = {
    for name, instance in oci_core_instance.swarm_nodes :
    name => instance.public_ip
  }
}

output "swarm_nodes_private_ips" {
  description = "IPs privados das VMs do cluster Swarm"
  value = {
    for name, instance in oci_core_instance.swarm_nodes :
    name => instance.private_ip
  }
}
