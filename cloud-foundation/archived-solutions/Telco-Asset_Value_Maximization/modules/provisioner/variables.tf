# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "host" {}

variable "private_key" {}

variable "atp_url" {
    default = ""
}

variable "db_password" {
    default = ""
}

variable "conn_db" {
    default = ""
}

variable "db_name" {
  default = ""
}

variable "dbhostname" {
  default = ""
}

variable "llmpw" {
    default = ""
}

# oac automation script variables

variable "Oracle_Analytics_Instance_Name" {
  default = ""
}

variable "Tenancy_Name" {
  default = ""
}

variable "bucket" {
  default = ""
}

variable "Authorization_Token" {
  default = ""
}

variable "ociRegion" {
  default = ""
}

variable "ociTenancyId" {
  default = ""
}

variable "ociUserId" {
  default = ""
}

variable "ociKeyFingerprint" {
  default = ""
}

variable "ociPrivateKeyWrapped" {
  default = ""
}

variable "home_region_for_oac" {
  default = ""
}


