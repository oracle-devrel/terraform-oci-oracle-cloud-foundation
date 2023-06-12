## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "dataflow_params" {
  type = map(object({
    compartment_id               = string
    application_display_name     = string
    application_driver_shape     = string
    application_executor_shape   = string
    application_file_uri         = string
    application_language         = string
    application_num_executors    = number
    application_spark_version    = string
    application_class_name       = string
    defined_tags                 = map(string)
    freeform_tags                = map(string)
    logs_bucket_uri              = string
    dns_zones                    = list(string)
    subnet_id                    = string
    description                  = string
    display_name                 = string
    max_host_count               = number
    nsg_ids                      =  list(string)
    }
  ))
}

