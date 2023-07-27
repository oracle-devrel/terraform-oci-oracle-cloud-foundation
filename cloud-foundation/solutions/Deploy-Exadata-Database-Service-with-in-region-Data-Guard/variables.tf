# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.14.0"
}


variable "tenancy_ocid" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = ""
}

variable "compartment_id" {
  type    = string
  default = ""
}

variable "user_ocid" {
  type    = string
  default = ""
}

variable "fingerprint" {
  type    = string
  default = ""
}

variable "private_key_path" {
  type    = string
  default = ""
}


############################################################
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

variable "backup_subnet_cidr" {
  default = "10.0.2.0/24"
}

############################################################

# Bastion Instance Variables: 
# Oracle-Linux-Cloud-Developer-8.5-2022.05.22-0 image  

variable "bastion_source_image_id" {
  type = map(string)
  default = {
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaabcomraotpw6apg7xvmc3xxu2avkkqpx4yj7cbdx7ebcm4d52halq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaa52kiqhwcoprmwfiuwureucv7nehqjfofoicwptpixdphzvon2mua"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa7nqsxvp4vp25gvzcrvld6xaiyxaxmzepkb5gz6us5sfkgeeez2zq"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaham2gnbrst3s46jrwchlnl3uqo7yxij7f3pqdzwx7zybu657347q"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaab5yi4bbnabymexkvwcdjlcjiue26kf3vz6dvzm6dvpttqcpaj5q"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaagvgnze6oq5il7b26onoq4daeaqrghp5hx4yp3q3rvtfpnbzq4zhq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaid5v36623wk7lyoivnqwygyaxppqfbzyo35wifxs7hkqo5caxhqa"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3mdtxzi5rx2ids2tb74wmm77zvsqdaxbjlgvjpr4ytzc5njtksjq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa22wjczcl7udl7w7e347zkwig7mh5p3zfbcemzs46jiaeom5lznyq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaaq6ggb4u6p4fgsdcj7o2p4akt5t7gmyjnvootiytrqc5joe5pmfq"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaas4cu36z32iraul5otar4gl3uy4s5jkupcc4m5shfqlatjiwaoftq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaakrtvc67c6thtmhrwphecd66omeytl7jmv3zd2bci74j56r4xodwq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaghsie5mvgzb6fbfzujidzrg7jnrraqkh6qkyh2vw7rl6cdnbpe6a"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2sj43nffpmyqlubrj4cikfgoij7qyqhymlnhw3bj7t26lh46euia"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaao3swjyengmcc5rz3ynp2euqskvcscqwgouzs3smaarxofxbwstcq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaaetscnayepwj2lto7mpgiwtom4jwkqafr3axumt3pt32cgwczkexq"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaavht3nwv7qsue7ljexbqqgofogwvrlgybvtrxylm52eg6b6xrgniq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaafavk2azn6cizxnugwi7izvxsumhiuzthw6g7k2o4vuhg4l3phi3a"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaakpex24z6rmmyvdeop72nomfui5t54lztix7t5mblqii4l7v4iecq"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaafgok5gj36cnrsqo6a3p72wqpg45s3q32oxkt45fq573obioliiga"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaappsxkscys22g5tha37tksf6rlec3tm776dnq7dcquaofeqqb6rna"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaawmvmgfvthguywgry23pugqqv2plprni37sdr2jrtzq6i6tmwdjwa"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaatqcxvjriek3gdndhk43fdss6hmmd47fw2vmuq7ldedr5f555vx5q"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaouprplh2bubqudrghr46tofi3bukvtrdgiuvckylpk4kvmxyhzda"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaqudryedi3l4danxy5kxbwqkz3nonewp3jwb5l3tdcikhftthmtga"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaogu4pvw4zw2p7kjabyynczopoqipecr2gozdaolh5kem2mkdrloa"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa57khlnd4ziajy6wwmud2d6k3wsqkm4yce3mlzbgxeggpbu3yqbpa"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaanod2kc3bw5l3myyd5okw4c46kapdpsu2fqgyswf4lka2hrordlla"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaevwlof26wfzcoajtlmykpaev7q5ekqyvkpqo2sjo3gdwzygu7xta"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaanajb7uklrra5eq2ewx35xfi2aulyohweb2ugik7kc6bdfz6swyha"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaameaqzqjwp45epgv2zywkaw2cxutz6gdc6jxnrrbb4ciqpyrnkczq"
  }
}

variable "bastion_instance_display_name" {
  type    = string
  default = "VNC-Bastion"
}

variable "bastion_instance_shape" {
  type    = string
  default = "VM.Standard2.4"
}

# ##########
# ## Exadata Infrastructure:
# ##########

# #############  First AD
# # Create Exadata Infrastrucutre in First AD

variable "exadata_infrastructure_first_availability_domain" {
  type    = number
  default = 1
}

variable "exadata_infrastructure_firstAD_display_name" {
  type    = string
  default = "exacs-firstAD"
}

variable "exadata_infrastructure_firstAD_shape" {
  type    = string
  default = "Exadata.Quarter3.100"
}

variable "exadata_infrastructure_firstAD_email" {
  type    = string
  default = "ionel.panaitescu@oracle.com"
}

variable "exadata_infrastructure_firstAD_preference" {
  type    = string
  default = "NO_PREFERENCE"
}


# # Create Cloud VM Cluster in First AD

variable "cloud_vm_cluster_firstAD_cpu_core_count" {
  type    = number
  default = 4
}

variable "cloud_vm_cluster_firstAD_display_name" {
  type    = string
  default = "exacs-firstad-vm"
}

variable "cloud_vm_cluster_firstAD_gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "cloud_vm_cluster_firstAD_hostname" {
  type    = string
  default = "exacs-firstad-vm"
}

variable "cloud_vm_cluster_firstAD_cluster_name" {
  type    = string
  default = "cl-exa1"
}

variable "cloud_vm_cluster_firstAD_data_storage_percentage" {
  type    = number
  default = 60
}

variable "cloud_vm_cluster_firstAD_is_local_backup_enabled" {
  type    = string
  default = "false"
}

variable "cloud_vm_cluster_firstAD_is_sparse_diskgroup_enabled" {
  type    = string
  default = "true"
}

variable "cloud_vm_cluster_firstAD_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "cloud_vm_cluster_firstAD_scan_listener_port_tcp" {
  type    = number
  default = 1521
}

variable "cloud_vm_cluster_firstAD_scan_listener_port_tcp_ssl" {
  type    = number
  default = 2484
}

variable "cloud_vm_cluster_firstAD_time_zone" {
  type    = string
  default = "UTC"
}

# # Create the DB Home and database in First AD

variable "database_db_home_firstAD_admin_password" {
  type    = string
  default = "PAr0lamea-#1"
}

variable "database_db_home_firstAD_db_version" {
  type    = string
  default = "19.0.0.0"
}

variable "database_db_home_firstAD_display_name" {
  type    = string
  default = "dbhome-dbsj"
}

variable "database_db_home_firstAD_db_name" {
  type    = string
  default = "dbsj"
}

variable "database_db_home_firstAD_source" {
  type    = string
  default = "VM_CLUSTER_NEW"
}

############################################################


#############  SECOND AD
# Create Exadata Infrastrucutre in Second AD

variable "exadata_infrastructure_second_availability_domain" {
  type    = number
  default = 2
}

variable "exadata_infrastructure_secondAD_display_name" {
  type    = string
  default = "exacs-secondAD"
}

variable "exadata_infrastructure_secondAD_shape" {
  type    = string
  default = "Exadata.Quarter3.100"
}

variable "exadata_infrastructure_secondAD_email" {
  type    = string
  default = "ionel.panaitescu@oracle.com"
}

variable "exadata_infrastructure_secondAD_preference" {
  type    = string
  default = "NO_PREFERENCE"
}

# # Create Cloud VM Cluster in Second AD

variable "cloud_vm_cluster_secondAD_cpu_core_count" {
  type    = number
  default = 4
}

variable "cloud_vm_cluster_secondAD_display_name" {
  type    = string
  default = "exacs-secondad-vm"
}

variable "cloud_vm_cluster_secondAD_gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "cloud_vm_cluster_secondAD_hostname" {
  type    = string
  default = "exacs-secondad-vm"
}

variable "cloud_vm_cluster_secondAD_cluster_name" {
  type    = string
  default = "cl-exa2"
}

variable "cloud_vm_cluster_secondAD_data_storage_percentage" {
  type    = number
  default = 60
}

variable "cloud_vm_cluster_secondAD_is_local_backup_enabled" {
  type    = string
  default = "false"
}

variable "cloud_vm_cluster_secondAD_is_sparse_diskgroup_enabled" {
  type    = string
  default = "true"
}

variable "cloud_vm_cluster_secondAD_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "cloud_vm_cluster_secondAD_scan_listener_port_tcp" {
  type    = number
  default = 1521
}

variable "cloud_vm_cluster_secondAD_scan_listener_port_tcp_ssl" {
  type    = number
  default = 2484
}

variable "cloud_vm_cluster_secondAD_time_zone" {
  type    = string
  default = "UTC"
}

# ############################################################

# Data Guard Association variables:

variable "database_data_guard_association_creation_type" {
  type    = string
  default = "ExistingVmCluster"
}

variable "database_data_guard_association_protection_mode" {
  type    = string
  default = "MAXIMUM_PERFORMANCE"
}

variable "database_data_guard_association_transport_type" {
  type    = string
  default = "ASYNC"
}

# ############################################################
