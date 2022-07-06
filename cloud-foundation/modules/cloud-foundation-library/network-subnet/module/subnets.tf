
# creates subnets, security lists and NSGs
# NSGs are recommended, but some apps need security lists


# inputs

# subnet
# how should we try to create cidr blocks? : http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
variable "cidr_block" {
  type = string
}


# routing
# technically we could get all of the gateway ocids from the vcn ocid and data sources
# TODO: needs to be implemented, but need to understand DRG, attachments, DRG route tables and route advertisements, and create network connection module first
variable "dynamic_routing_gateway_list" {
  type        = list(string)
  default     = []
  description = "creates a route rule for each drg ocid in the list"
}

variable "subnet_dns_label" {
  type    = string
  default = null
}


/* expected defined values
var.compartment - ocid
var.vcn - ocid
var.service_gateway - bool
data.oci_core_service_gateways.this[0].service_gateways[0].services[0].service_id

var.internet_access - string (full, nat, none)
data.oci_core_nat_gateways.this[0].id
data.oci_core_internet_gateways.this[0].id

*/


# outputs

output "subnet_id" {
  value = oci_core_subnet.this.id
}

output "subnet_cidr" {
  value = oci_core_subnet.this.cidr_block
}

# logic

locals {
  prefix = var.prefix == null ? "" : "${var.prefix}-"
}




# resource or mixed module blocks



resource "oci_core_route_table" "this" {
  #Required
  compartment_id = var.compartment
  vcn_id         = var.vcn

  display_name = "${local.prefix}RT"

  dynamic "route_rules" {
    for_each = var.service_gateway && !var.internet_access ? { "create" = true } : {}
    content {
      network_entity_id = data.oci_core_service_gateways.this[0].service_gateways[0].id

      description      = "Allow Service Gateway routing"
      destination      = data.oci_core_services.this[0].services[0].cidr_block
      destination_type = "SERVICE_CIDR_BLOCK"
    }
  }

  dynamic "route_rules" {
    for_each = var.internet_access == "nat" ? { "create" = true } : {}
    content {

      network_entity_id = data.oci_core_nat_gateways.this[0].nat_gateways[0].id
      description       = "Allow Nat Gateway routing for egress internet traffic"
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  dynamic "route_rules" {
    for_each = var.internet_access == "full" ? { "create" = true } : {}
    content {

      network_entity_id = data.oci_core_internet_gateways.this[0].gateways[0].id
      description       = "Allow Internet Gateway routing"
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }

  dynamic "route_rules" {
    for_each = toset(var.dynamic_routing_gateway_list)
    content {
      network_entity_id = route_rules.value
      description       = "DRG route rule"
      destination       = "TODO how do we get this value"
      destination_type  = "CIDR_BLOCK"
    }
  }
}





resource "oci_core_subnet" "this" {

  cidr_block     = var.cidr_block
  compartment_id = var.compartment
  vcn_id         = var.vcn


  display_name = "${local.prefix}SN"
  dns_label = var.subnet_dns_label

  #dns_label    = var.subnet_dns_label

  prohibit_public_ip_on_vnic = var.internet_access != "full" ? true : false

  route_table_id    = oci_core_route_table.this.id
  security_list_ids = [oci_core_security_list.this.id]
}
