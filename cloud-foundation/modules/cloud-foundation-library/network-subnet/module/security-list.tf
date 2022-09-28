# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# inputs

variable "all_outbound_traffic" {
  type        = bool
  default     = true
  description = "creates security rule allowing all egress traffic out to anywhere"
}

variable "ssh_cidr" {
  type        = string
  default     = null
  description = "the cidr block to allow ssh traffic on. Common values are 0.0.0.0/0 your vcn cidr or your bastion subnet cidr"
}

variable "standard_icmp" {
  type        = bool
  default     = true
  description = "if true, turns on some standard icmp traffic"
}

variable "icmp_ingress_cidrs" {
  type = list(string)
  default = []
  description = "list of cidr blocks to allow all icmp traffic from"
}

variable "icmp_egress_cidrs" {
  type = list(string)
  default = []
  description = "list of cidr blocks to allow all icmp traffic out to"
}

variable "icmp_egress_service" {
  type = bool 
  default = false 
  description = "if true, allows all icmp traffic out to oracle services network"
}


variable "custom_tcp_ingress_rules" {
  type = map(object({
        source_cidr   = string,
        min = number,
        max = number,
  }))

  default = {}
  description = "creates stateful tcp security list rules to a range of destination ports from any port with a specific source cidr"
}
variable "tcp_all_ports_ingress_cidrs" {
  type = list(string)
  default = []
  description = "used to create stateful tcp security list rules to all destination ports from the given list of source cidrs"
}

variable "custom_tcp_egress_rules" {
  type = map(object({
    dest_cidr = string,
    min = number,
    max = number
  }))
  
  default = {}
  description = "creates statefull tcp security list rules from a range of destination ports to any port with a specific destination cidr"
}
variable "tcp_all_ports_egress_cidrs" {
  type = list(string)
  default = []
  description = "used to creste stateful rcp security list rules from all destination ports to the given list of source cidrs"
}

/* expected defined values
var.compartment - ocid
var.vcn - ocid
local.prefix - string
local.cidr_blocks

var.service_gateway
local.service_cidr
*/

# outputs 


# logic


locals {


}

# resource or mixed module blocks



resource "oci_core_security_list" "this" {
  #Required
  compartment_id = var.compartment
  vcn_id         = var.vcn

  display_name = "${local.prefix}SL"


# Egress Rules

  dynamic "egress_security_rules" {
    for_each = var.all_outbound_traffic ? { "create" = true } : {}
    content {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "allow all types of outbound traffic anywhere"
    }
  }

  dynamic "egress_security_rules" {
    //allow custom tcp traffic to specific ports from any port in a specific cidr range
    for_each = var.custom_tcp_egress_rules
    content {
      protocol = "6"
      destination   = egress_security_rules.value.dest_cidr
      tcp_options {
          min = egress_security_rules.value.min
          max = egress_security_rules.value.max
      }
    }
  }
  dynamic "egress_security_rules" {
    //allows tcp traffic from all ports
    for_each = toset(var.tcp_all_ports_egress_cidrs)
    content {
      protocol = "6"
      destination = egress_security_rules.value
    }
  }


  dynamic "egress_security_rules" {
    for_each = var.icmp_egress_service ? { "create" = true } : {}
    content {
      protocol    = "1"
      destination_type = "SERVICE_CIDR_BLOCK"
      destination = local.service_cidr
      description = "allow all outbound icmp traffic to oracle services network"
    }
  }
  
  dynamic "egress_security_rules" {
    for_each = toset(var.icmp_egress_cidrs)
    content {
      protocol    = "1"
      destination = egress_security_rules.value
      description = "allow all outbound icmp traffic to given cidr"
    }
  }

  dynamic "egress_security_rules" {
    //allow traffic to the Oracle Services Network via SGW
    for_each = var.service_gateway && var.internet_access != "full" ? { "create" = true } : {}
    content {
      protocol = "6"
      destination_type = "SERVICE_CIDR_BLOCK"
      destination   = local.service_cidr
    }
  }



# Ingress Rules

  dynamic "ingress_security_rules" {
    for_each = var.ssh_cidr != null ? { "create" = true } : {}
    content {
      protocol = "6"
      source   = var.ssh_cidr
      tcp_options {
        min = 22
        max = 22
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.standard_icmp ? { "create" = true } : {}
    content {
      // allow ICMP for all type 3 code 4
      protocol = "1"
      source   = "0.0.0.0/0"

      icmp_options {
        type = "3"
        code = "4"
      }
    }
  }

  dynamic "ingress_security_rules" {
    //allow type 3 ICMP from all VCN CIDRs
    for_each = var.standard_icmp ? toset(local.cidr_blocks) : toset([])
    content {
      protocol = "1"
      source   = ingress_security_rules.value # might be more readable to use an iterator
      icmp_options {
        type = "3"
        code = null #no code reverts to -1
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = toset(var.icmp_ingress_cidrs)
    content {
      protocol    = "1"
      source = ingress_security_rules.value
      description = "allow all inbound icmp traffic from given cidr"
    }
  }

dynamic "ingress_security_rules" {
    //allow traffic to the Oracle Services Network via SGW
    for_each = var.service_gateway && var.internet_access != "full" ? { "create" = true } : {}
    content {
      protocol = "6"
      source_type = "SERVICE_CIDR_BLOCK"
      source   = local.service_cidr
    }
  }


  dynamic "ingress_security_rules" {
    //allow custom tcp traffic to specific ports from any port in a specific cidr range
    for_each = var.custom_tcp_ingress_rules
    content {
      protocol = "6"
      source   = ingress_security_rules.value.source_cidr

      tcp_options { # TODO: should we add explicit destination port range object
          min = ingress_security_rules.value.min
          max = ingress_security_rules.value.max
      }
    }
  }
  dynamic "ingress_security_rules" {
    //allows tcp traffic to all ports
    for_each = toset(var.tcp_all_ports_ingress_cidrs)
    content {
      protocol = "6"
      source = ingress_security_rules.value
    }
  }

}
