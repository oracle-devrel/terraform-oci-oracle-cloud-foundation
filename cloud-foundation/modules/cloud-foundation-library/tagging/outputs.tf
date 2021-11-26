output "tag_namespace" {
  value = [ for b in oci_identity_tag_namespace.this : b.name]
}

output "tag_keys" {
  value = [ for b in oci_identity_tag.this : b.name]
}