# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.14.0"
}

variable "tenancy_ocid" {
  type = string
  default = ""
}

variable "region" {
    type = string
    default = ""
}

variable "compartment_id" {
  type = string
  default = ""
}

variable "user_ocid" {
    type = string
    default = ""
}

variable "fingerprint" {
    type = string
    default = ""
}

variable "private_key_path" {
    type = string
    default = ""
}


# Autonomous Database Configuration Variables

variable "adw_cpu_core_count" {
    type = number
    default = 1
}

variable "adw_size_in_tbs" {
    type = number
    default = 1
}

variable "adw_db_name" {
    type = string
    default = "ADWipnEBS"
}

variable "adw_db_workload" {
    type = string
    default = "DW"
}

variable "adw_db_version" {
    type = string
    default = "19c"
}

variable "adw_enable_auto_scaling" {
    type = bool
    default = true
}

variable "adw_is_free_tier" {
    type = bool
    default = false
}

variable "adw_license_model" {
    type = string
    default = "LICENSE_INCLUDED"
}

variable "database_admin_password" {
  type = string
  default = "" # Example password: Par0laMea123
}

variable "database_wallet_password" {
  type = string
  default = "" # Example password: Par0laMea123
}


# Oracle Analytics Cloud Configuration

variable "analytics_instance_feature_set" {
    type    = string
    default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
    type    = string
    default = "LICENSE_INCLUDED"
}

variable "analytics_instance_hostname" {
    type    = string
    default = "AnalyicSDEBS"
}

variable "analytics_instance_idcs_access_token" {
    type    = string
    default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
    type    = string
    default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
    type    = number
    default = 2
}

variable "analytics_instance_network_endpoint_details_network_endpoint_type" {
    type    = string
    default = "public"
}

variable "whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "analytics_instance_network_endpoint_details_whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}


# Data Catalog

variable "datacatalog_display_name" {
    type    = string
    default = "DataCatalogIP"
}


# Bastion Instance variables
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

variable "bastion_instance_image_ocid" {
  type = map(string)
  default = {
    ap-chuncheon-1	= "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaihmt2keujm4pd3wswehk3ybcs4d4guuapvml7slexmwgjxwjaypq"
    ap-hyderabad-1	= "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaawcl3nadtbiijdrrrczdfh2bqbujtaswfviu5rf3dc2hldetikuzq"
    ap-melbourne-1	= "ocid1.image.oc1.ap-melbourne-1.aaaaaaaayrgmmffm34ikswpqlsc3rlu74vofqrypuo6srgvl6nhpccwkbdqq"
    ap-mumbai-1	    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaayg64ftz6kq7y4zbvohti67pzn2yxioweb3yfscwqeq5urccnmcvq"
    ap-osaka-1	    = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa4rzsgxccrowpua6nn6pujztlyrcmhdgd6gsgsgo4ikuvhgy3ihia"
    ap-seoul-1	    = "ocid1.image.oc1.ap-seoul-1.aaaaaaaayze2sndwv7uwwgltjvhjhy3n2rr5nr7wbrernzberaxzcm6iyepq"
    ap-sydney-1	    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaahjlvew72o4dg5h5ok76tew7d5rw3s6hfng7xystxj6fxinxdixca"
    ap-tokyo-1	    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaazou4xzdvfawk23xzeury3a33gvo4i3fmyzxlchpptsqnwpyrayrq"
    ca-montreal-1	  = "ocid1.image.oc1.ca-montreal-1.aaaaaaaazwrlosyjzkech4pokwrgi6mnzfvtjjeya6mj5rhimtf4i6ag3aoa"
    ca-toronto-1	  = "ocid1.image.oc1.ca-toronto-1.aaaaaaaarqogbrbjbgnpvio6im4yiz564kpgq6q35jk66q2h4a53cxnqgqeq"
    eu-amsterdam-1	= "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa3wwms4s2asbn6isysx6qexsppsh725cbh5wuv6u466znhj64u64a"
    eu-frankfurt-1	= "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7lzlvp6re2qyum4vmyryjk2okyfj7vp7lj2rd6qk2ovp7yfssoxa"
    eu-zurich-1	    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaab6njbd32zxehpsvliwjujewg5jqow3vxmv5nr3wbvfomuc6lzv4a"
    me-dubai-1	    = "ocid1.image.oc1.me-dubai-1.aaaaaaaa7wybi5o7rye52jp5uj3bu5ccwofgxjjeo54gsers4j6lnfhrtuaq"
    me-jeddah-1	    = "ocid1.image.oc1.me-jeddah-1.aaaaaaaazk2fffaxgc5534lze5ojxai4vnxuxiz4k57s3joafi26hbby5w6a"
    sa-santiago-1	  = "ocid1.image.oc1.sa-santiago-1.aaaaaaaafchgyo6a4sa4h6edkvijohbcwnroafhb66sbe3come5d5qhj4noq"
    sa-saopaulo-1	  = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaawisuo2l655it3yw5oaq7lrf6wh7dyof22yk23ek47cnxfcpkgfia"
    sa-vinhedo-1	  = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaae2g4ystqi35snjnp2nn25cvmkh74ngpm45uqosmh7ukgurnalkuq"
    uk-cardiff-1	  = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaamijlpruvprwtaovx26yvun5tuijutfmmk6npcbawsfmgrv6fyc3a"
    uk-london-1	    = "ocid1.image.oc1.uk-london-1.aaaaaaaaqb6vgjln2bsdvlkdk2eqov5hhqbyffodkto2qimvab4mvh4q567q"
    us-ashburn-1	  = "ocid1.image.oc1.iad.aaaaaaaatw76yshzzwmu6l7rdpsv3kpfnanubwtdhjbrhelz4n7sz7ss5s6q"
    us-phoenix-1	  = "ocid1.image.oc1.phx.aaaaaaaavb7udllf45sc5whsgcsmzmbiqb73rpysi3t5nuy5jil3yocfsoka"
    us-sanjose-1	  = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaicbcb5sfq6n5iisvx2hfr2vroifs4jmzgvuvizo7m32m2tlzzx6q"
  }
}

# ODI Instance variables
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm

variable "odi_instance_shape" {
  default = "VM.Standard2.4" # Example instance shape: VM.Standard2.4
}

variable "adw_username" {
  type = string
  default = "admin" # Example username: admin
}

variable "adw_password" {
  type = string
  default = "" # Example password: Par0laMea123
}

variable "odi_vnc_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "odi_schema_prefix" {
  type = string
  default = "odi" # Example schema prefix: odi
}

variable "odi_schema_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "odi_password" {
  type = string
  default = ""   # Example password: Par0laMea123
}

variable "adw_creation_mode" {
  type = bool
  default = true  # True - As we are using ADW not mysql
}

variable "embedded_db" {
  type = bool
  default = false  # False - As we are using ADW not mysql embeded 
}

variable "studio_mode" {
  type = string
  default = "ADVANCED"  # "ADVANCED" or "Web"
}

variable "db_tech" {
  type = string
  default = "ADB"  # DB Tech ADB not Mysql
}

variable "studio_name" {
  type = string
  default = "ADVANCED" #  "ADVANCED" ,  "ODI Web Studio Administrator" or "ODI Studio"
}


# Networking variables

# VCN and subnet Variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "service_name" {
  type        = string
  default     = "IonelP"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}

# # don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}

# # End
