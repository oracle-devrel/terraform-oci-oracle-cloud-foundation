# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "exadata_infrastructure" {
  type = map(object({
    availability_domain = number
    compartment_id      = string
    display_name        = string
    shape               = string
    email               = string
    defined_tags        = map(string)
    freeform_tags       = map(string)
    hours_of_day        = list(number)
    preference          = string
    weeks_of_month      = list(number)
  }))
}