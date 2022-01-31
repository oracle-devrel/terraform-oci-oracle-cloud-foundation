## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "deployment_params" {
  type = map(object({
    compartment_id          = string
    cpu_core_count          = number
    deployment_type         = string
    subnet_id               = string
    license_model           = string
    display_name            = string
    is_auto_scaling_enabled = bool
    defined_tags            = map(string)
    ogg_data = set(object(
      {
        admin_password  = string
        admin_username  = string
        deployment_name = string
      }
    ))
  }))
}