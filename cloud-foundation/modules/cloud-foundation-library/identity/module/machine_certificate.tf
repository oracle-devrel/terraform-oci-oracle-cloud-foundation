
# inputs

variable "enable_ca" {
    default = false
    type = bool
    description = "if true, creates dynamic group and policy enabling Certificate Authorities to use keys and manage objects in the security compartment"
}


/* expected values 
oci_identity_compartment.security - resource
    - id and name
*/

# outputs


# logic


# resource or mixed module blocks

resource "oci_identity_dynamic_group" "Certificate_Authority" {
    count = var.enable_ca ? 1 : 0
    compartment_id = var.tenancy_ocid
    description = "all CAs in ${oci_identity_compartment.security[0].name} compartment"
    matching_rule = "All{resource.type='certificateauthority', instance.compartment.id='oci_identity_compartment.security[0].id'}"
    name = "${oci_identity_compartment.security[0].name}-certificate-authority"
}

resource "oci_identity_policy" "Certificate_Authority" {
    count = var.enable_ca ? 1 : 0

    compartment_id = oci_identity_compartment.security[0].id
    description = "enables CA dynamic group to use keys and manage object in security compartment"
    name = "${oci_identity_compartment.security[0].name}-certificate-authority"
    statements = concat(
      formatlist("allow dynamic-group ${oci_identity_dynamic_group.Certificate_Authority[0].name} to %s in compartment ${oci_identity_compartment.security[0].name}", [
        "use keys", "manage objects"
      ]),
    )
}