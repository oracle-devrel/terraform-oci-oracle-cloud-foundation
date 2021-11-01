output "zones" {
  value = [for zone in oci_dns_zone.this:
    {"id": zone.id, "name": zone.name}
  ]
}

output "records" {
  value = [for record in oci_dns_rrset.this:
    {"domain": record.domain, "data": [for item in record.items: item.rdata]}
  ]
}
