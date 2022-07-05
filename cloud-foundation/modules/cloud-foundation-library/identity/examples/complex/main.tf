


# inputs


# outputs


# logic


# resource or mixed module blocks


module "core-identity" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=<input latest git tag>"
    source = "../../module"

    # tenancy level groups and policies
    create_announcement_persona = true 
    create_auditor_persona = true 
    create_cost_persona = true
    create_general_persona = true 
    create_identity_persona = true

    # compartment structure
    tenancy_ocid = var.tenancy_ocid
   
    # Standard IT compartments, groups, and policies
    create_database_persona = true
    create_network_persona = true 
    create_security_persona = true

}


module "dept1-identity" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=<input latest git tag>"
    source = "../../module"


    # compartment structure
    tenancy_ocid = var.tenancy_ocid
    enclosing_compartment_name = "department"
    prefix = "Dept1"

   
    # Standard IT compartments, groups, and policies
    create_application_persona = true
    application_name = "MyApp"
    application_environments = ["Prod", "Non-Prod"]
}
module "dept1-app2" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=<input latest git tag>"
    source = "../../module"

    # compartment structure 
    tenancy_ocid = var.tenancy_ocid 
    existing_compartment = module.dept1-identity.enclosing_compartment

    # Standard IT compartments, groups, and policies
    create_application_persona = true
    application_name = "MyApp2"
    application_environments = ["Prod", "Non-Prod", "dev", "test"]
}



module "dept2-identity" {
    # pick a source type - github url with path and git tag is recommended for production code. local path is used for sub-module development and customization
    # source = "github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation//cloud-foundation/modules/cloud-foundation-library/identity/module?ref=<input latest git tag>"
    source = "../../module"


    # compartment structure
    tenancy_ocid = var.tenancy_ocid
    enclosing_compartment_name = "department"
    prefix = "Dept2"

   
    # Standard IT compartments, groups, and policies
    create_application_persona = true
    application_name = "MyApp"
    application_environments = ["Prod", "Non-Prod"]
    create_database_persona = true
    database_name = "DB"

    create_custom_persona = true 
    custom_persona_name = "Sandbox"
    custom_policy_permissions = ["manage all-resources"]

}