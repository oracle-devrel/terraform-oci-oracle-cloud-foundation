## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  streaming_poolID = {
    for stream_pool in oci_streaming_stream_pool.this :
    stream_pool.name => stream_pool.id
  }
}

locals {
  streaming_ID = {
    for stream in oci_streaming_stream.this :
    stream.name => stream.id
  }
}

output "streaming_poolID" {
  value = local.streaming_poolID
}

output "streaming_ID" {
  value = local.streaming_ID
}