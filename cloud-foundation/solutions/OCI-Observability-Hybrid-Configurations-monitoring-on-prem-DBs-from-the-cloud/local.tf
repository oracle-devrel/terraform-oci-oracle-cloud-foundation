# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  register_external_container_db = {
    container1 = {
      compartment_id                           = var.compartment_id,
      external_container_display_name          = "container1"
    },
  }

  register_external_pluggable_db = {
    pdb1 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb1"
    },
    pdb2 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb2"
    },
    pdb3 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb3"
    },
    pdb4 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb4"
    },
    pdb5 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb5"
    },
    pdb6 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb6"
    },
    pdb7 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb7"
    },
    pdb8 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb8"
    },
    pdb9 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb9"
    },
    pdb10 = {
      compartment_id                           = var.compartment_id,
      external_container_name                  = "container1"
      external_pluggable_database_display_name = "pdb10"
    },
  }


  # Container Databases:

  connector_external_container_db = {
    container1 = {
      external_container_name                                            = "container1"
      oci_database_connector_agent_id                                    = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                           = "container1"
      external_database_connector_connection_credentials_credential_type = "DETAILS"
      external_database_connector_connection_credentials_credential_name = "dbname1212.1234567891"
      external_database_connector_connection_credentials_password        = "password_here"
      external_database_connector_connection_credentials_role            = "NORMAL"
      external_database_connector_connection_credentials_username        = "username"
      external_database_connector_connection_string_hostname             = "ip_address"
      external_database_connector_connection_string_port                 = 1521
      external_database_connector_connection_string_protocol             = "TCP"
      external_database_connector_connection_string_service              = "service"
      external_database_connector_connector_type                         = "MACS"
      enable_database_management_for_external_containers_database        = true
      license_model                                                      = "BRING_YOUR_OWN_LICENSE"
    }
  }

  # Pluggable Databases

  connector_external_pluggable_db = {
    pdb1 = {
      external_pluggable_name                                               = "pdb1"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection1_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname1212.12345678912"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }
    pdb2 = {
      external_pluggable_name                                               = "pdb2"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection2_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2121.123456789113"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb3 = {
      external_pluggable_name                                               = "pdb3"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection3_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2212.123456789114"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb4 = {
      external_pluggable_name                                               = "pdb4"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection4_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2213.123456789115"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb5 = {
      external_pluggable_name                                               = "pdb5"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection5_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2214.123456789116"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb6 = {
      external_pluggable_name                                               = "pdb6"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection6_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2215.123456789117"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb7 = {
      external_pluggable_name                                               = "pdb7"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection7_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2216.123456789118"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

    pdb8 = {
      external_pluggable_name                                               = "pdb8"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection8_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2217.123456789119"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb9 = {
      external_pluggable_name                                               = "pdb9"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection9_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2218.1234567891110"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }


    pdb10 = {
      external_pluggable_name                                               = "pdb10"
      external_container_name                                               = "container1"
      oci_database_connector_agent_id                                       = "ocid1.managementagent.oc1.iad.amaaaaaaknuwtjiaosq5ztq3fu7kzvoh6u6"
      external_database_connector_display_name                              = "connection10_pluggable_db"
      external_database_connector_connection_credentials_credential_type    = "DETAILS"
      external_database_connector_connection_credentials_credential_name    = "dbname2219.1234567891111"
      external_database_connector_connection_credentials_password           = "password_here"
      external_database_connector_connection_credentials_role               = "NORMAL"
      external_database_connector_connection_credentials_username           = "username"
      external_database_connector_connection_string_hostname                = "ip_address"
      external_database_connector_connection_string_port                    = 1521
      external_database_connector_connection_string_protocol                = "TCP"
      external_database_connector_connection_string_service                 = "service"
      external_database_connector_connector_type                            = "MACS"
      enable_database_management_for_external_pluggable_database            = true
      enable_operations_insights_management_for_external_pluggable_database = true
    }

  }


  # # End

}
