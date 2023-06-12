# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "containers_artifacts" {
  value       = length(oci_artifacts_container_repository.this) > 0 ? oci_artifacts_container_repository.this[*] : null
}



