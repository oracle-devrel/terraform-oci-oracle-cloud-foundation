# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "waf_params" {
  type = map(object({
    compartment_id   = string
    backend_type     = string
    display_name     = string
    load_balancer_id = string
    defined_tags     = map(string)
    freeform_tags    = map(string)
  }))
}
