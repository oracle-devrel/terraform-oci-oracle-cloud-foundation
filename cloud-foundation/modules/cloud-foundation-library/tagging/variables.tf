# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {}

variable "tags" {
description = "ArchitectureCenterTagNamespace"
type = list(object({
  tag_namespace = string
  tag_namespace_description = string
  tag_name = list(string)
  }))
}