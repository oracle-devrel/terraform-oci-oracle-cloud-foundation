## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {
    type = string
}
variable "streaming_params" {
  type = map(object({
    name               = string
    partitions         = number
    compartment_id     = string
    retention_in_hours = number
    stream_pool_id     = string
    stream_pool_name   = string
    defined_tags       = map(string)
    }
  ))
}
variable "streaming_pool_params" {
  type = map(object({
    compartment_id = string
    name           = string
    defined_tags   = map(string)
    kafka_settings = list(object({
      auto_create_topics_enable = bool
      log_retention_hours       = number
      num_partitions            = number
      #Optional
      //        bootstrap_servers = string
    }))
    #Optional
    //    defined_tags = map(string)
    //    private_endpoint_settings  = set(object({
    //        nsg_ids = list(string)
    //        private_endpoint_ip = string
    //        subnet_id = string
    //    }
    //    ))
    }
  ))
}

variable "service_connector" {
  type = map(object({
    compartment_id                                        = string
    service_connector_display_name                        = string
    service_connector_source_kind                         = string
    service_connector_source_cursor_kind                  = string
    service_connector_target_kind                         = string
    service_connector_target_batch_rollover_size_in_mbs   = number
    service_connector_target_batch_rollover_time_in_ms    = number
    service_connector_target_bucket                       = string
    service_connector_target_object_name_prefix           = string
    service_connector_description                         = string
    defined_tags                                          = map(string)
    service_connector_tasks_kind                          = string
    service_connector_tasks_batch_size_in_kbs             = number
    service_connector_tasks_batch_time_in_sec             = number
    function_id                                           = string
    }
  ))
}
