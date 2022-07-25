

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

variable "service_gateway_id" {
  type = string 
  default = null 
  description = "optional variable to designate service gateway. If null, but service_gateway is true, it will attempt to find the sgw via datasource"
}
variable "service_cidr" {
  type = string 
  default = null 
  description = "optional variable used when the service gateway id is declared. This is the service cidr used by the service gateway"
}


variable "internet_access" {
    type = string
    default = "none"
    description = "Defines the level of internet access to give the subment. Valid values(gateway): full(IGW), nat(NGW), none"
}
variable "network_gateway_id" {
  type = string 
  default = null 
  description = "optional variable to designate a network (nat or internet) gateway. If null, but internet_access is full or nat, it will attempt to find the appropriate gateway via datasource"
}



# outputs

locals {
    cidr_blocks = data.oci_core_vcn.this.cidr_blocks

    service_gateway = (var.service_gateway && var.service_gateway_id == null 
        ?  data.oci_core_service_gateways.this[0].service_gateways[0].services[0].service_id
        : var.service_gateway_id
    )

    service_cidr = (var.service_gateway && var.service_cidr == null 
        ? data.oci_core_services.this[0].services[0].cidr_block 
        : var.service_cidr
    )

    network_gateway = ( var.internet_access == "none"
        ? null 
        : var.network_gateway_id != null 
          ? var.network_gateway_id
          : var.internet_access == "full"
            ? data.oci_core_internet_gateways.this[0].gateways[0].id
            : data.oci_core_nat_gateways.this[0].nat_gateways[0].id
    )

    

}

# logic

data "oci_core_vcn" "this" {
  vcn_id = var.vcn
}

data "oci_core_service_gateways" "this" {
    count = var.service_gateway && var.service_gateway_id == null ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}
# service gateway does not contain name of service cidr block, so we need to extract from services datasource
data "oci_core_services" "this" {
    count = var.service_gateway && var.service_cidr == null ? 1 : 0

  filter {
    name   = "name"
    values = [data.oci_core_service_gateways.this[0].service_gateways[0].services[0].service_id]
  }
  
}


data "oci_core_nat_gateways" "this" {
    count = var.internet_access == "nat" && var.network_gateway_id == null ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}

data "oci_core_internet_gateways" "this" {
    count = var.internet_access == "full" && var.network_gateway_id == null ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn
}

# resource or mixed module blocks