#OCI authentication

tenancy_ocid=<tenancy_ocid>
user_ocid=<user_ocid>
fingerprint=<fingerprint>
private_key_path=<private_key_path>
region=<region>
compartment_ocid=<compartment_ocid>
compartment_policy_id=<compartment_policy_id>

#Network Information

network_compartment_id = <netork_compartment_id>
existing_vcn_id = <existing_vcn_id>
wls_subnet_id = <wls_subnet_id>
add_load_balancer = <true|false>
lb_subnet_id = <lb_subnet_id>
existing_bastion_instance_id = <existing_bastion_instance_id>
bastion_host = <bastion_host>

#Service Name

service_name = <service_name>

#Weblogic

instance_image_id = <instance_image_id>
instance_shape = <shape>

wls_admin_user = <wls_admin_user>
wls_admin_password_ocid = <wls_admin_password_ocid>
use_regional_subnet = <true|false>
wls_version = <wls_version>
wls_node_count = <wls_node_count>

#Keys

ssh_public_key = <ssh_public_key>
bastion_ssh_private_key = <bastion_ssh_private_key>

#ATP DB - JRF Domain

create_atp_db = <true|false>
atp_db_level = <atp_db_level>
atp_db_password_ocid = <atp_db_password_ocid>
atp_db_compartment_id = <atp_db_compartment_id>
autonomous_database_cpu_core_count= <atp_cpu_count>
autonomous_database_db_name=<atp_db_name>
autonomous_database_admin_password=<atp_db_password_base64>
autonomous_database_data_storage_size_in_tbs=<storage_size>

#atp_db_id = <atp_db_id>
