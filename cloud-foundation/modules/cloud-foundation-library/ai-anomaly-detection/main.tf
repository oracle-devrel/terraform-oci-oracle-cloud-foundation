# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "user_namespace" {
  compartment_id = var.tenancy_ocid
}

resource "oci_ai_anomaly_detection_project" "this" {
    for_each       = var.ai_anomaly_detection_project_params
    compartment_id = each.value.compartment_id
    description    = each.value.description
    display_name   = each.value.display_name
    defined_tags   = each.value.defined_tags
}


data "oci_ai_anomaly_detection_project" "existing" {
    for_each       = var.ai_anomaly_detection_project_params
    project_id     = oci_ai_anomaly_detection_project.this[each.key].id
}


resource "oci_ai_anomaly_detection_data_asset" "this" {
    for_each       = var.ai_anomaly_detection_data_asset_params
    compartment_id = each.value.compartment_id
    data_source_details {
        data_source_type = each.value.data_source_type
        bucket = each.value.bucket
        measurement_name = each.value.measurement_name
        # namespace = each.value.namespace
        namespace = data.oci_objectstorage_namespace.user_namespace.namespace
        object = each.value.object
        version_specific_details {
              influx_version = each.value.influx_version
            bucket = each.value.bucket
        }
    }
    project_id     = oci_ai_anomaly_detection_project.this[each.value.project_name].id
    description    = each.value.description
    display_name   = each.value.display_name
    defined_tags   = each.value.defined_tags
}


data "oci_ai_anomaly_detection_data_asset" "existing" {
    for_each       = var.ai_anomaly_detection_data_asset_params
    data_asset_id  = oci_ai_anomaly_detection_data_asset.this[each.key].id
}


resource "oci_ai_anomaly_detection_model" "this" {
    for_each       = var.ai_anomaly_detection_model_params
    compartment_id = each.value.compartment_id
    model_training_details {
        # data_asset_ids = each.value.data_asset_ids
        data_asset_ids = [data.oci_ai_anomaly_detection_data_asset.existing[each.value.display_name].id]
        target_fap = each.value.target_fap
        training_fraction = each.value.training_fraction
    }
    project_id = oci_ai_anomaly_detection_project.this[each.value.project_name].id
    description    = each.value.description
    display_name   = each.value.display_name
    defined_tags   = each.value.defined_tags
}


data "oci_ai_anomaly_detection_model" "existing" {
    for_each       = var.ai_anomaly_detection_model_params
    model_id = oci_ai_anomaly_detection_model.this[each.key].id
}




