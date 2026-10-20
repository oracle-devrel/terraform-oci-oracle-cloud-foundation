# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.30.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key          = local.effective_oci_private_key_pem != "" ? local.effective_oci_private_key_pem : null
  private_key_path     = local.effective_oci_private_key_pem == "" ? var.private_key_path : null
  region               = var.region
  disable_auto_retries = false
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

provider "oci" {
  alias                = "homeregion"
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key          = local.effective_oci_private_key_pem != "" ? local.effective_oci_private_key_pem : null
  private_key_path     = local.effective_oci_private_key_pem == "" ? var.private_key_path : null
  region               = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  disable_auto_retries = false
}
