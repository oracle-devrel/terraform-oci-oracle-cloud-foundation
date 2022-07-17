## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "oci_data_safe_private_endpoint_params" {
  type = map(object({
    compartment_id = string
    display_name   = string
    description    = string
    vcn_id         = string
    subnet_id      = string
    nsg_ids        = list(string)
    defined_tags   = map(string)
  }))
}
