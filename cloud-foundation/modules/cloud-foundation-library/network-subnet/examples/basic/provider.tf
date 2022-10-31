# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


#Auth Vars
variable "tenancy_ocid" {}
variable "region" {}
variable "current_user_ocid" {}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}



provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.current_user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"

}

terraform {

  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.79.0, < 5.0.0"
    }
  }
}