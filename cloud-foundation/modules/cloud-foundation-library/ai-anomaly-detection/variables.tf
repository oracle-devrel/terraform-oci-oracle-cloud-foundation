# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "ai_anomaly_detection_project_params" {
  type = map(object({
    compartment_id = string
    description    = string
    display_name   = string
    defined_tags   = map(string)
  }))
}

variable "ai_anomaly_detection_data_asset_params" {
  type = map(object({
    compartment_id   = string
    project_name     = string
    data_source_type = string
    bucket           = string
    measurement_name = string
    # namespace        = string
    object           = string
    influx_version   = string
    description      = string
    display_name     = string
    defined_tags     = map(string)
  }))
}

variable "ai_anomaly_detection_model_params" {
  type = map(object({
    compartment_id    = string
    # data_asset_ids   = list(string)
    project_name      = string
    target_fap        = string
    training_fraction = string
    description       = string
    display_name      = string
    defined_tags      = map(string)
  }))
}

