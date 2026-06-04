# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "adb" {
  source     = "./modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params
}

module "mongodb_atlas" {
  count  = var.mongo_mode == "atlas" ? 1 : 0
  source = "./modules/cloud-foundation-library/mongodb-atlas"

  org_id        = var.mongodb_atlas_org_id
  project_name  = var.mongodb_atlas_project_name
  cluster_name  = var.mongodb_atlas_cluster_name
  atlas_region  = var.mongodb_atlas_region
  db_username   = var.mongodb_db_username
  db_password   = var.mongodb_db_password
  database_name = var.mongodb_database_name
}

module "os" {
  source       = "./modules/cloud-foundation-library/object-storage"
  depends_on   = [module.adb]
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k, v in local.bucket_params : k => v if v.compartment_id != ""
  }
}

module "network-vcn" {
  source               = "./modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.vcns-lists : k => v if v.compartment_id != ""
  }
}

module "network-subnets" {
  source               = "./modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.subnet-lists : k => v if v.compartment_id != ""
  }
}

module "network-routing" {
  source         = "./modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id = var.compartment_id
  subnets_route_tables = {
    for k, v in local.subnets_route_tables : k => v if v.compartment_id != ""
  }
}

module "network-routing-attachment" {
  source               = "./modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id       = var.compartment_id
  subnets_route_tables = local.network-routing-attachment
}

module "network-security-lists" {
  source                               = "./modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id                       = var.compartment_id
  ports_not_allowed_from_anywhere_cidr = []
  security_lists = {
    for k, v in local.security_lists : k => v if v.compartment_id != ""
  }
}

module "network-security-groups" {
  source         = "./modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id
  nsgs           = local.nsgs-lists
}

module "keygen" {
  source = "./modules/cloud-foundation-library/keygen"
}

module "web-instance" {
  source          = "./modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid    = var.tenancy_ocid
  instance_params = local.instance_params
}

module "cart_api_gateway" {
  source = "./modules/cloud-foundation-library/oci-api-gateway-cart"

  compartment_id          = var.compartment_id
  subnet_id               = lookup(module.network-subnets.subnets, "public-subnet").id
  gateway_display_name    = "jc-iad-apigw-hub"
  deployment_display_name = "fashion-store-cart-api"
  endpoint_type           = "PUBLIC"
  path_prefix             = "/v1"
  execution_log_level     = "INFO"
  enable_access_log       = false
  defined_tags            = {}

  http_routes = [
    {
      path                   = "/api/v1/cart/items"
      methods                = ["POST"]
      url                    = "http://${module.web-instance.InstancePublicIPs[0]}:5000/api/v1/cart/items"
      connect_timeout        = 60
      read_timeout           = 10
      send_timeout           = 10
      is_ssl_verify_disabled = false
    }
  ]

  stock_routes = [
    {
      path    = "/cart"
      methods = ["GET"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "text/html" }]
    },
    {
      path    = "/api/cart/update"
      methods = ["POST"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/cart/remove"
      methods = ["POST"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart"
      methods = ["GET"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart"
      methods = ["POST"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/items/{product_id}"
      methods = ["DELETE"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/items/{product_id}"
      methods = ["PATCH"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/clear"
      methods = ["POST"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/shipping-address"
      methods = ["PUT"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/coupons"
      methods = ["POST"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/coupons/{coupon_code}"
      methods = ["DELETE"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    },
    {
      path    = "/api/v1/cart/summary"
      methods = ["GET"]
      status  = 200
      body    = ""
      headers = [{ name = "Content-Type", value = "application/json" }]
    }
  ]
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

resource "null_resource" "upload_wallet_to_object_storage" {
  depends_on = [module.adb, module.os]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      WALLET_ZIP="wallet_${var.atp_db_name}.zip"
      NAMESPACE="${data.oci_objectstorage_namespace.this.namespace}"
      BUCKET="${var.atp_creds_bucket_name}"

      if [ ! -f "$WALLET_ZIP" ]; then
        echo "ERROR: Wallet zip not found: $WALLET_ZIP"
        exit 1
      fi

      TMP_DIR="$(mktemp -d)"
      trap 'rm -rf "$TMP_DIR"' EXIT

      echo "Unzipping $WALLET_ZIP to $TMP_DIR ..."
      unzip -o "$WALLET_ZIP" -d "$TMP_DIR" >/dev/null

      echo "Uploading wallet contents to bucket: $BUCKET (namespace: $NAMESPACE) ..."
      cd "$TMP_DIR"

      find . -type f -print0 | while IFS= read -r -d '' f; do
        obj_name="$${f#./}"
        echo " -> $obj_name"
        oci os object put -ns "$NAMESPACE" -bn "$BUCKET" --force --name "$obj_name" --file "$f" >/dev/null
      done

      echo "Done."
    EOT
  }
}

resource "null_resource" "upload_files_to_object_storage" {
  depends_on = [module.os]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      SOURCE_DIR="${path.root}/fashion-articles"
      NAMESPACE="${data.oci_objectstorage_namespace.this.namespace}"
      BUCKET="${var.files_bucket_name}"

      if [ ! -d "$SOURCE_DIR" ]; then
        echo "ERROR: Source directory not found: $SOURCE_DIR"
        exit 1
      fi

      echo "Uploading files from $SOURCE_DIR to bucket: $BUCKET (namespace: $NAMESPACE) ..."

      cd "$SOURCE_DIR"

      find . -type f -print0 | while IFS= read -r -d '' f; do
        obj_name="$${f#./}"
        echo " -> $obj_name"
        oci os object put \
          -ns "$NAMESPACE" \
          -bn "$BUCKET" \
          --force \
          --name "$obj_name" \
          --file "$f" >/dev/null
      done

      echo "Done."
    EOT
  }
}

module "provisioner" {
  source = "./modules/provisioner"
  depends_on = [
    module.adb,
    module.keygen,
    module.web-instance,
    module.os,
    module.cart_api_gateway,
    null_resource.upload_wallet_to_object_storage,
    null_resource.upload_files_to_object_storage,
    module.mongodb_atlas
  ]

  host                  = module.web-instance.InstancePublicIPs[0]
  private_key           = module.keygen.OPCPrivateKey["private_key_pem"]
  atp_url               = module.adb.adw_sql_dev_web_urls
  db_password           = var.adw_db_password
  db_name               = var.adw_db_name
  atp_db_name           = var.atp_db_name
  atp_db_password       = var.atp_db_password
  conn_db               = module.adb.high_mutual_connection_string["adw"]
  conn_db_atp           = module.adb.high_mutual_connection_string["atp"]
  atp_creds_bucket_name = var.atp_creds_bucket_name

  compartment_id      = var.compartment_id
  atp_wallet_zip_path = "${path.root}/wallet_${var.atp_db_name}.zip"
  service_selector    = "_tp"

  oci_user_ocid        = trimspace(var.user_ocid)
  oci_tenancy_ocid     = trimspace(var.tenancy_ocid)
  oci_fingerprint      = trimspace(var.fingerprint)
  oci_private_key_pem  = local.effective_oci_private_key_pem
  objectstorage_region = var.region

  api_gateway_hostname   = module.cart_api_gateway.gateway_hostname
  rag_region             = var.rag_region
  genai_embedding_region = var.genai_embedding_region
  rag_compartment_id     = var.compartment_id
  files_bucket_name      = var.files_bucket_name
  cart_items_api_url     = "${module.cart_api_gateway.deployment_endpoint}/api/v1/cart/items"
  cart_summary_api_url   = "${module.cart_api_gateway.deployment_endpoint}/api/v1/cart/summary"

  select_ai_model_nl2sql    = var.select_ai_model_nl2sql
  select_ai_model_agent     = var.select_ai_model_agent
  select_ai_model_rag       = var.select_ai_model_rag
  select_ai_embedding_model = var.select_ai_embedding_model

  mongo_mode = var.mongo_mode

  mongodb_hostname = local.mongodb_hostname
  mongodb_db_name  = local.mongodb_db_name
  mongodb_username = local.mongodb_username
  mongodb_password = local.mongodb_password

  oracle_mongo_url = try(module.adb.mongo_db_urls["atp"], "")

  mongo_uri = (
    var.mongo_mode == "atlas" ? module.mongodb_atlas[0].mongodb_uri :
    var.mongo_mode == "oracle_api" ? replace(
      replace(
        try(module.adb.mongo_db_urls["atp"], ""),
        "[user:password@]",
        "${var.oracle_mongo_username}:${var.oracle_mongo_password}@"
      ),
      "[user]",
      var.oracle_mongo_schema
    ) :
    ""
  )

  mongo_db_name = (
    var.mongo_mode == "atlas" ? module.mongodb_atlas[0].database_name :
    var.mongo_mode == "oracle_api" ? var.oracle_mongo_schema :
    ""
  )
}