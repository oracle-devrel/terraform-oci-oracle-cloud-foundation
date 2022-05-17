# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    oci = {
      source                = "oracle/oci"
      configuration_aliases = [oci.homeregion]
    }
  }
}