# OCI authentication

tenancy_ocid=<tenancy_ocid>
user_ocid=<user_ocid>
fingerprint=<fingerprint>
private_key_path=<private_key_path>
region=<region>
compartment_ocid=<compartment_ocid>
compartment_policy_id=<compartment_policy_id>

# Compute Shape of the VM's
instance_shape=<shape>

#Service Name
service_name = <service_name>

#Network Information

create_policies = <true|false>
use_regional_subnet = <true|false>
vcn_name = <vcn_name>
vcn_cidr = <vcn_cidr>

add_load_balancer = <true|false>

wls_subnet_cidr = <wls_subnet_cidr>
lb_subnet_cidr = <lb_subnet_cidr>
lb_subnet_backend_cidr = <lb_subnet_backend_cidr>
bastion_subnet_cidr = <bastion_subnet_cidr>
network_compartment_id = <network_compartment_id>

ssh_public_key = "ssh_public_key.pem"

#WLS info

wls_admin_password_ocid = "ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaattkvkkiafdd64mtznq4lnefxmmxvorgcsvrgbpymm2sumkznirza"
wls_version = <wls_version>

#ATP info

is_atp_db = <true|false>
atp_db_password_ocid = <atp_db_password_ocid>
atp_db_compartment_id = <atp_db_compartment_id>