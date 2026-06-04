# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "display_name" {
    description = "Display Name for organization."
    default = "common"
}

variable "subnet_domain_name" {
    default = "subnet_domain"
}

variable "organization" {
    default = "Demo"
}

variable "organizational_unit" {
    default = "FOR TESTING ONLY"
}