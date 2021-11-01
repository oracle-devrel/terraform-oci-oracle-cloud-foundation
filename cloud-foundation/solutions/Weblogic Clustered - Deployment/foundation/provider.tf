/*
* ORM only requires region to be defined for provider.
* https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Tasks/usingconsole.htm
*/

provider "oci" {
  version = ">=3.27.0"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"

}

provider "oci" {
  alias = "home"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}


