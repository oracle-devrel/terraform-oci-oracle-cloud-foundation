# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "Buckets" {
  value = module.os.buckets
}

output "streaming_poolID" {
  value = module.streaming.streaming_poolID
}

output "streaming_ID" {
  value = module.streaming.streaming_ID
}

output "apps" {
  value = module.functions.apps
}

output "functions" {
  value = module.functions.functions
}

output "dataflow" {
  value = module.dataflowapp.dataflow
}

output "datascience" {
  value = module.datascience.datascience
}

output "notebook" {
  value = module.datascience.notebook
}
