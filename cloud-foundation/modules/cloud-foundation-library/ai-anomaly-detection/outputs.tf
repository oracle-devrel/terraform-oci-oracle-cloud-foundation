# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ai_anomaly_detection_project" {
  value = {
    for ai in oci_ai_anomaly_detection_project.this :
    ai.display_name => { "compartment_id" : ai.compartment_id, "id" : ai.id }
  }
}

output "ai_anomaly_detection_data_asset" {
  value = {
    for ai in oci_ai_anomaly_detection_data_asset.this :
    ai.display_name => { "id" : ai.id, "compartment_id" : ai.compartment_id }
  }
}

output "ai_anomaly_detection_model" {
  value = {
    for ai in oci_ai_anomaly_detection_model.this :
    ai.display_name => { "id" : ai.id, "compartment_id" : ai.compartment_id }
  }
}


