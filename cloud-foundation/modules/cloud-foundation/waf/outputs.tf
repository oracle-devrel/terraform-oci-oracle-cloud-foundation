output "cname" {
  value = { for waas in oci_waas_waas_policy.this :
    waas.display_name => waas.cname
  }
}

output "waas" {
  value = { for waas in oci_waas_waas_policy.this :
    waas.display_name => waas.id
  }
}
