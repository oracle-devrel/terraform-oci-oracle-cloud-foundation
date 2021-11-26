## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ids" {
  type = map(string)
}

variable "subnet_ids" {
  type = map(string)
}


variable "deployment_params" {
  type = map(object({
    compartment             = string
    cpu_core_count          = number
    deployment_type         = string
    subnet_id               = string
    license_model           = string
    display_name            = string
    is_auto_scaling_enabled = bool
    ogg_data = set(object(
      {
        admin_password  = string
        admin_username  = string
        deployment_name = string
        #optional params
        //      certificate     = string
        //      key             = string
      }
    ))
    #Optional paramenters
    //  fqdn = string
    //  freeform_tags = map(string)
    //  is_public = bool
    //  nsg_ids = set(string)
    //  defined_tags = map(string)
    //  deployment_backup_id = string
    //  description = string
  }))
}
