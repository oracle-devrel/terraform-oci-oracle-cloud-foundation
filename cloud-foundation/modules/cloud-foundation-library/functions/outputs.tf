// Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.

output "apps" {
  value = {
    for app in oci_functions_application.this:
      app.display_name => {"compartment_id": app.compartment_id, "ocid": app.id, "subnets":app.subnet_ids}
  }
}

output "functions" {
  value = {
    for fn in oci_functions_function.this:
      fn.display_name => {"compartment_id": fn.compartment_id, "ocid": fn.id, "image":fn.image, "Invoke endpoint" : fn.invoke_endpoint}
  }
}


output "function" {
  value = {
   for fn in oci_functions_function.this:
    fn.display_name => fn.id
  }
}