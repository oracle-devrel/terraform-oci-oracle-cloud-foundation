# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "tenancy_ocid" {
    type = string
}

variable "bucket_upload_params" {
  type = map(object({
    bucket = string
    object = string
    content = string
  }))
}