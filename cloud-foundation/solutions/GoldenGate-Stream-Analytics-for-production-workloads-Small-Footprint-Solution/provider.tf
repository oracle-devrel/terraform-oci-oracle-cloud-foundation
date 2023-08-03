# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.37.0"
    }
  }
}

provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  region               = var.region
  disable_auto_retries = false
}

provider "oci" {
  alias                = "homeregion"
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  region               = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  disable_auto_retries = false
}