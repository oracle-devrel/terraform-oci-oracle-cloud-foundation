# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    oci = {
      # source  = "oracle/oci"
      version = ">= 4.37.0"
      configuration_aliases = [
        oci.acceptor,
        oci.requestor,
      ]
    }
  }
}

provider "oci" {
  alias                = "first"
  region               = var.region
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  disable_auto_retries = false
}

provider "oci" {
  alias                = "second"
  region               = var.region2
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  disable_auto_retries = false
}


