# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartments" {
  description = "DNS Compartments OCIDs."
  type = map(string)
}

variable "instances" {
  description = "Instances OCIDs."
  type = map(any)
}

variable "load_balancer_params" {
  type = map(object({
    lb_id             = string
    comp_id           = string
  }))
}
variable "zone_params" {
  description = "The parameters of the zones: zone_name, zone_type, compartment_id"
  type        = map(object({
    compartment_name  = string
    zone_name         = string
    zone_type         = string
    external_masters  = list(object({
      ip    = string
    }))
  }))
}

variable dns_records_params {
  description = "The DNS records for the domains(zones)"
  type = map(object({
    zone_name        = string
    domain           = string
    rtype            = string

    dns_items = list(object({
      domain   = string
      rdata    = string
      rtype    = string
      ttl      = number
      use_lb        = bool
      use_instance  = bool
      lb_name       = string
      instance_name = string
    }))
  }))
}

variable dns_resolver_rules { 
    description = "DNS Resolver rules" 
    type = map(object({ 
        resolver_id =string, #fromdatasource 
        scope = string, # always PRIVATE 
        rules = list(object({ 
            action = string, 
            destination_address = string, 
            source_endpoint_name = string, 
            client_address_conditions = string, 
            #qname_cover_conditions = string, 
        })) 
    })) 
    default = {}
}


variable "dns_resolver_endpoints" { 
    description = "DNS resolvers endpoints" 
    type = map(object({ 
        is_forwarding = bool, 
        is_listening = bool, 
        resolver_id = string, 
        subnet_id = string, 
        scope = string, # always PRIVATE 
        endpoint_type = string, 
        forwarding_address = string, 
        listening_address = string, 
        nsg_ids = string, 
    })) 
    default = {}
}


