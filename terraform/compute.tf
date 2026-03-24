locals {
  instances = {
    "swarm-mgr" = {
      name       = "swarm-mgr"
      private_ip = "10.0.1.10"
    }
    "swarm-wkr-1" = {
      name       = "swarm-wkr-1"
      private_ip = "10.0.1.11"
    }
    "swarm-wkr-2" = {
      name       = "swarm-wkr-2"
      private_ip = "10.0.1.12"
    }
  }
}

resource "oci_core_instance" "swarm_nodes" {
  for_each            = local.instances
  compartment_id      = var.tenancy_ocid
  availability_domain = var.availability_domain
  display_name        = each.value.name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_subnet.id
    private_ip       = each.value.private_ip
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}
