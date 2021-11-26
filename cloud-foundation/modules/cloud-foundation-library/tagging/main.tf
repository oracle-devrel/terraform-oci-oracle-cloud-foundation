locals {
  tags = flatten([
  for tag in var.tags : [
  for tag_name in tag.tag_name : {
    namespace = tag.tag_namespace
    description = tag.tag_namespace_description
    tag = tag_name 
      }
    ]
  ])
}

resource "oci_identity_tag_namespace" "this" {
  compartment_id = var.compartment_id
  for_each = {
    for rc in var.tags :
    rc.tag_namespace => rc
  }
  name = each.value.tag_namespace
  description = each.value.tag_namespace_description

  provisioner "local-exec" {
  command = "sleep 120"
  }
}

resource "oci_identity_tag" "this" {
  for_each = {
    for t in local.tags :
    "${t.namespace}:${t.tag}" => t
  }
  name = each.value.tag
  description = each.value.description
  tag_namespace_id = oci_identity_tag_namespace.this[each.value.namespace].id
  
  provisioner "local-exec" {
  command = "sleep 120"
  }
}