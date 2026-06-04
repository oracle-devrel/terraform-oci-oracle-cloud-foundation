# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI API authentification credentials

terraform {
  required_version = ">= 0.14.0"
}

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_id" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
