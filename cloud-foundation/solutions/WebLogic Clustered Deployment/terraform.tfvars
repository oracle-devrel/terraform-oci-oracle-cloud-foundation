# OCI authentication

tenancy_ocid="<tenancy_ocid>"
user_ocid="<user_ocid>"
fingerprint="<fingerprint>"
private_key_path="<private_key_path>"
region="<region>"
compartment_ocid="<ompartment_ocid>"

#Network Information

network_compartment_id = "<network_compartment_id>"
compartment_policy_id = "<compartment_policy_id>"

wls_subnet_cidr = "<wls_subnet_cidr>"
lb_subnet_cidr = "<lb_subnet_cidr>" 
lb_subnet_backend_cidr = "<lb_subnet_backend_cidr>"
bastion_subnet_cidr = "<bastion_subnet_cidr>"

create_policies = "<true|false>"
vcn_name ="<vcn_name>"
vcn_cidr = "<vcn_cidr>"

add_load_balancer = <true|false>

linux_instance_image_id = "<linux_image_id for instance>"

#Service Name

service_name = "<proj_name>"

#Weblogic

instance_image_id = "<weblogic_image_id>"
image_version = "<image_version>"
instance_shape = "<image_shape>"

wls_admin_user = "<user>"
wls_admin_password_ocid = "<password>"
use_regional_subnet = "<true|false>"
wls_version = "<wls version>"
wls_node_count = "<wls nodes - number>"

#Keys

ssh_public_key = "<ssh public key>"

#ATP DB - JRF Domain

create_atp_db = <true|false>
atp_db_level = "<atp db level>"
atp_db_password_ocid = "<atp db password ocid from vault>"
atp_db_compartment_id = "<atp db compartment id>"
autonomous_database_cpu_core_count="<node count>"
autonomous_database_db_name="<db name>"
autonomous_database_admin_password="<db password>"
autonomous_database_data_storage_size_in_tbs="<storage size>"

#atp_db_id = "<atp db id if db exists and not creating it>"