


# inputs


# outputs


# logic


# resource or mixed module blocks


module "identity" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=v1.2.0"
    source = "../../module"

    # tenancy level groups and policies
    create_announcement_persona = true 
    create_auditor_persona = true 
    create_cost_persona = true
    create_general_persona = true 
    create_identity_persona = true

    # compartment structure
    tenancy_ocid = var.tenancy_ocid
    enclosing_compartment_name = "department"
    prefix = "MyDepartment"

   
    # Standard IT compartments, groups, and policies
    create_application_persona = true
    application_name = "MyApp"
    application_environments = ["Prod", "Non-Prod"]
    create_database_persona = true
    create_network_persona = true 
    create_security_persona = true


}