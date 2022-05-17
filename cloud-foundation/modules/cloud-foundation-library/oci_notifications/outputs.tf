# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "topics" {
  value = {
    for i in oci_ons_notification_topic.this :
    i.name => { "id" : i.topic_id, "api_endpoint" : i.api_endpoint, "short_topic_id" : i.short_topic_id }
  }
}


output "topic_id" {
  value = { for i in oci_ons_notification_topic.this :
  i.name => i.topic_id }
}
