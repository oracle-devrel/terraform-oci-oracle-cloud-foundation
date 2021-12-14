# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "instance_params" {

  type = map(object({

    availability_domain = number
    compartment_id      = string
    display_name        = string
    shape               = string

    defined_tags = map(string)
    freeform_tags = map(string)

    subnet_id        = string
    vnic_display_name = string
    assign_public_ip = string
    hostname_label   = string
  
    source_type = string
    source_id   = string

    metadata = map(string)
    
    fault_domain = string
 
    provisioning_timeout_mins = string
    
}))

}
