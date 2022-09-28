# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# TODO flesh out this module - currently just a dump from refactoring subnet module



# inputs

variable "vcn_id" {
  type = string 
  description = "The OCID of an existing vcn to load data resources from"
  
}

variable "service_gateway" {
  type = bool 
  default = true 
  description = "If true(default), loads the service gateway data resources"
}

variable "nat_gateway" {
  type = bool 
  default = true 
  description = "If true(default), loads the nat gateway data resource"
}

variable "internet_gateway" {
  type = bool 
  default = true 
  description = "If true(default), loads the internet gateway data resource"
}

# outputs

output "vcn" {
  value = data.oci_core_vcn.this.id
  description = "ocid of created vcn"
}

output "cidrs" {
  value = data.oci_core_vcn.this.cidr_blocks
}

output "service_gateway" {
  value = var.service_gateway ? data.oci_core_service_gateways.this[0].id : null
  description = "ocid of created SGW"
}

output "service_cidr" {
  value = var.service_gateway ? data.oci_core_services.this[0].services[0].cidr_block : null
  description = "the service cidr used by the service gateway"
}

output "nat_gateway" {
  value = var.nat_gateway ? data.oci_core_nat_gateways.this[0].nat_gateways[0].id : null
  description = "ocid of created NGW"
}

output "internet_gateway" {
  value = var.internet_gateway ? data.oci_core_internet_gateways.this[0].gateways[0].id : null
  description = "ocid of created IGW"
}


# logic


data "oci_core_vcn" "this" {
  vcn_id = var.vcn_id
}

data "oci_core_service_gateways" "this" {
    count = var.service_gateway ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn_id
}
# service gateway does not contain name of service cidr block, so we need to extract from services datasource
data "oci_core_services" "this" {
    count = var.service_gateway ? 1 : 0

  filter {
    name   = "name"
    values = [data.oci_core_service_gateways.this[0].service_gateways[0].services[0].service_id]
  }
  
}


data "oci_core_nat_gateways" "this" {
    count = var.nat_gateway ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn_id
}

data "oci_core_internet_gateways" "this" {
    count = var.internet_gateway ? 1 : 0

    compartment_id = data.oci_core_vcn.this.compartment_id
    vcn_id = var.vcn_id
}


# resource or mixed module blocks