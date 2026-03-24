resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.tenancy_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "lab-devops-vcn"
  dns_label      = "labdevops"
}

resource "oci_core_internet_gateway" "lab_igw" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "lab-devops-igw"
  enabled        = true
}

resource "oci_core_route_table" "lab_rt" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "lab-devops-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.lab_igw.id
  }
}

resource "oci_core_subnet" "lab_subnet" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "lab-devops-subnet"
  dns_label         = "labsubnet"
  route_table_id    = oci_core_route_table.lab_rt.id
  security_list_ids = [oci_core_vcn.lab_vcn.default_security_list_id]
}
