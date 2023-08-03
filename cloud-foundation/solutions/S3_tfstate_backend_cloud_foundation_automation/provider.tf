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

# Example of terraform s3 backend in OCI
terraform {
  backend "s3" {
    bucket   = "statefiles"
    key      = "solutions/Remote_tfstate_file_S3_backend_and_github_actions_automations.tfstate"
    region   = "us-ashburn-1"
    endpoint = "https://oradbclouducm.compat.objectstorage.us-ashburn-1.oraclecloud.com"
    shared_credentials_file     = "~/.aws/credentials"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
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