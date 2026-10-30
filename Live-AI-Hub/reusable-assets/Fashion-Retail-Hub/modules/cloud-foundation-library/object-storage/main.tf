# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "os" {
  for_each = {
    for k, v in var.bucket_params : k => v if v.compartment_id != ""
  }
  compartment_id        = each.value.compartment_id
  name                  = each.value.name
  namespace             = data.oci_objectstorage_namespace.os.namespace
  access_type           = each.value.access_type
  storage_tier          = each.value.storage_tier
  object_events_enabled = each.value.events_enabled
  defined_tags          = each.value.defined_tags

  lifecycle {
    # OCI adds system-defined Oracle-Tags after bucket creation.
    ignore_changes = [defined_tags]
  }

  # OCI does not expose a force-delete argument on this bucket resource. The
  # bucket resource itself must empty its objects before deletion; attaching
  # the provisioner here makes it work even when the stack is destroyed before
  # a separately-added cleanup null_resource has ever been applied.
  provisioner "local-exec" {
    when = destroy

    command = <<-EOT
      set -euo pipefail
      command -v oci >/dev/null 2>&1 || {
        echo "OCI CLI is required to empty bucket ${self.name} before destroy." >&2
        exit 127
      }

      echo "Emptying Object Storage bucket ${self.name} before destroy ..."
      oci os object bulk-delete-versions \
        --namespace-name "${self.namespace}" \
        --bucket-name "${self.name}" \
        --force
      oci os object bulk-delete \
        --namespace-name "${self.namespace}" \
        --bucket-name "${self.name}" \
        --force
      echo "Emptied Object Storage bucket ${self.name}."
    EOT
  }
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.30.0"
    }
  }
  required_version = ">= 1.5.5"
}
