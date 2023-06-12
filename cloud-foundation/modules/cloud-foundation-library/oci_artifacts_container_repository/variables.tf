# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "containers_artifacts_params" {
  type = map(object({
    compartment_id   = string
    display_name     = string
    is_immutable     = bool
    is_public        = bool
  }))
}


