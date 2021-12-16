## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "datascience_params" {
  type = map(object({
    compartment_id       = string
    project_description  = string
    project_display_name = string
    defined_tags         = map(string)
    }
  ))
}
variable "notebook_params" {
  type = map(object({
    project_name = string
    compartment_id                                                 = string
    notebook_session_notebook_session_configuration_details_shape  = string
    subnet_id                                                      = string
    notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs = number
    notebook_session_display_name = string
    defined_tags = map(string)
    }
  ))
}