

# inputs
variable "vcn" {
    type = string 
    description = "The OCID of an existing vcn to create the subnet in"
  
}
variable "compartment" {
  type = string 
  description = "ocid of the compartment to create resources in."
}
variable "prefix" {
    type = string 
    default = null
    description = "the prefix to append to each resource's name"
}

variable "service_gateway" {
 type = bool 
    default = true
    description = "if true(default), creates routes and SL rule to the Oracle Services Network via the VCNs SGW. Assumes 1 SGW in the vcn"
}
variable "internet_access" {
    type = string
    default = "none"
    description = "Defines the level of internet access to give the subment. Valid values(gateway): full(IGW), nat(NGW), none"
}

# outputs

locals {
    cidr_blocks = data.oci_core_vcn.this.cidr_blocks

    
}

# logic

data "oci_core_vcn" "this" {
  vcn_id = var.vcn
}

data "oci_core_service_gateways" "this" {
    count = var.service_gateway ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}
# service gateway does not contain name of service cidr block, so we need to extract from services datasource
data "oci_core_services" "this" {
    count = var.service_gateway ? 1 : 0

  filter {
    name   = "name"
    values = [data.oci_core_service_gateways.this[0].service_gateways[0].services[0].service_name]
    regex  = true
  }
  
}


data "oci_core_nat_gateways" "this" {
    count = var.internet_access == "nat" ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}

data "oci_core_internet_gateways" "this" {
    count = var.internet_access == "full" ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}

# resource or mixed module blocks