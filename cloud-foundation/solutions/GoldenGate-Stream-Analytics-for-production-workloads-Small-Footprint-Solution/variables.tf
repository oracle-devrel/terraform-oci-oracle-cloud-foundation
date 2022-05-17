# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI API authentification credentials

terraform {
  required_version = ">= 0.14.0"
}

variable "tenancy_ocid" {
  default = ""
}

variable "user_ocid" {
  default = ""
}

variable "fingerprint" {
  default = ""
}

variable "private_key_path" {
  default = ""
}

variable "region" {
  default = ""
}

variable "compartment_id" {
  default = ""
}

# Compute Configuration
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
# "Web-Tier-and-Bastion" variables

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

# "Workers" variables

variable "worker1_shape" {
  default = "VM.Standard2.4"
}

variable "worker2_shape" {
  default = "VM.Standard2.4"
}

variable "worker3_shape" {
  default = "VM.Standard2.4"
}


# "Masters" variables

variable "master1_shape" {
  default = "VM.Standard2.4"
}

variable "master2_shape" {
  default = "VM.Standard2.4"
}


# Network variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}
