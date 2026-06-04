# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    local = {
      source = "hashicorp/local"
    }
    oci = {
      source = "oracle/oci"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

data "external" "atp_wallet_meta" {
  program = ["bash", "${path.module}/read_wallet_and_cert.sh"]

  query = {
    wallet_zip       = var.atp_wallet_zip_path
    service_selector = var.service_selector
  }
}

locals {
  app_db_env = var.mongo_mode == "oracle_api" ? "oracle_adb" : (var.mongo_mode == "atlas" ? "atlas" : "oracle_sql")

  oracle_runtime_user     = "cohub"
  oracle_runtime_password = "AaBbCcDdEe123#"
  oracle_runtime_dsn      = "${lower(var.db_name)}_tp"
  oracle_runtime_wallet   = "/home/opc/wallet_${var.db_name}"

  effective_oci_user_ocid    = trimspace(var.oci_user_ocid)
  effective_oci_tenancy_ocid = trimspace(var.oci_tenancy_ocid)
  effective_oci_fingerprint  = trimspace(var.oci_fingerprint)
  effective_oci_private_key  = trimspace(replace(var.oci_private_key_pem, "\r", ""))

  oci_private_key_sql = replace(local.effective_oci_private_key, "'", "''")

  adw_cohub_user_sql = templatefile("${path.module}/adw-co-hub-v0.01-cohub-user.sql.tftpl", {
    mongo_mode       = var.mongo_mode
    mongodb_hostname = var.mongodb_hostname
    mongodb_db_name  = var.mongodb_db_name
    mongodb_username = var.mongodb_username
    mongodb_password = var.mongodb_password

    oci_user_ocid       = local.effective_oci_user_ocid
    oci_tenancy_ocid    = local.effective_oci_tenancy_ocid
    oci_fingerprint     = local.effective_oci_fingerprint
    oci_private_key_sql = local.oci_private_key_sql

    objectstorage_region    = var.objectstorage_region
    objectstorage_namespace = data.oci_objectstorage_namespace.this.namespace
    atp_creds_bucket_name   = var.atp_creds_bucket_name

    atp_hostname           = data.external.atp_wallet_meta.result.hostname
    atp_port               = data.external.atp_wallet_meta.result.port
    atp_service_name       = data.external.atp_wallet_meta.result.service_name
    atp_ssl_server_cert_dn = data.external.atp_wallet_meta.result.ssl_server_cert_dn

    rag_region              = var.rag_region
    genai_embedding_region  = var.genai_embedding_region
    rag_compartment_id      = var.rag_compartment_id
    files_bucket_name       = var.files_bucket_name
    cart_items_api_url      = var.cart_items_api_url
    cart_summary_api_url    = var.cart_summary_api_url

    select_ai_model_nl2sql    = var.select_ai_model_nl2sql
    select_ai_model_agent     = var.select_ai_model_agent
    select_ai_model_rag       = var.select_ai_model_rag
    select_ai_embedding_model = var.select_ai_embedding_model
  })

  adw_admin_user_sql = templatefile("${path.module}/adw-co-hub-v0.01-admin-user.sql.tftpl", {
    api_gateway_hostname = var.api_gateway_hostname
  })

  atp_co_mongo_setup_sql = templatefile("${path.module}/atp-co-mongo-setup.sql.tftpl", {})

  adw_ai_profiles_oracle_sql = templatefile("${path.module}/adw_ai_profiles_oracle.sql.tftpl", {
    rag_region                = var.rag_region
    select_ai_model_nl2sql    = var.select_ai_model_nl2sql
    select_ai_model_agent     = var.select_ai_model_agent
  })

  adw_analytics_oracle_api_sql = templatefile("${path.module}/adw_analytics_oracle_api.sql.tftpl", {
    rag_region             = var.rag_region
    select_ai_model_nl2sql = var.select_ai_model_nl2sql
    select_ai_model_agent  = var.select_ai_model_agent
  })
}

resource "local_sensitive_file" "adw_cohub_user_sql" {
  filename = "${path.module}/adw-co-hub-v0.01-cohub-user.generated.sql"
  content  = local.adw_cohub_user_sql
}

resource "local_sensitive_file" "adw_admin_user_sql" {
  filename = "${path.module}/adw-co-hub-v0.01-admin-user.generated.sql"
  content  = local.adw_admin_user_sql
}

resource "local_file" "atp_co_mongo_setup_sql" {
  content  = local.atp_co_mongo_setup_sql
  filename = "${path.module}/atp-co-mongo-setup.sql"
}

resource "local_sensitive_file" "adw_ai_profiles_oracle_sql" {
  filename = "${path.module}/adw_ai_profiles_oracle.generated.sql"
  content  = local.adw_ai_profiles_oracle_sql
}

resource "local_sensitive_file" "adw_analytics_oracle_api_sql" {
  filename = "${path.module}/adw_analytics_oracle_api.generated.sql"
  content  = local.adw_analytics_oracle_api_sql
}

resource "null_resource" "remote-exec" {
depends_on = [
  local_sensitive_file.adw_cohub_user_sql,
  local_sensitive_file.adw_admin_user_sql,
  local_file.atp_co_mongo_setup_sql,
  local_sensitive_file.adw_ai_profiles_oracle_sql,
  local_sensitive_file.adw_analytics_oracle_api_sql
]

  provisioner "file" {
    source      = "wallet_${var.db_name}.zip"
    destination = "/home/opc/wallet_${var.db_name}.zip"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "wallet_${var.atp_db_name}.zip"
    destination = "/home/opc/wallet_${var.atp_db_name}.zip"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/file_envs.sh"
    destination = "/tmp/file_envs.sh"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "${path.module}/adw-co-hub-v0.01-admin-user.generated.sql"
    destination = "/home/opc/adw-co-hub-v0.01-admin-user.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/cohub-create_tables_ddl.sql"
    destination = "/home/opc/cohub-create_tables_ddl.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/cohub-product_catalog.sql"
    destination = "/home/opc/cohub-product_catalog.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/co_install.sql"
    destination = "/home/opc/co_install.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/co_create.sql"
    destination = "/home/opc/co_create.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/co_populate.sql"
    destination = "/home/opc/co_populate.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "${path.module}/adw-co-hub-v0.01-cohub-user.generated.sql"
    destination = "/home/opc/adw-co-hub-v0.01-cohub-user.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "${path.module}/atp-co-mongo-setup.sql"
    destination = "/home/opc/atp-co-mongo-setup.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/fashion-retail-app-2026-02-10-11-53.zip"
    destination = "/home/opc/fashion-retail-app-2026-02-10-11-53.zip"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/co-customer_profile.csv"
    destination = "/home/opc/co-customer_profile.csv"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/sync_mongo_atp_to_adw.py"
    destination = "/home/opc/sync_mongo_atp_to_adw.py"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/adw_customer_profile_function_oracle.sql"
    destination = "/home/opc/adw_customer_profile_function_oracle.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

provisioner "file" {
  source      = "${path.module}/adw_ai_profiles_oracle.generated.sql"
  destination = "/home/opc/adw_ai_profiles_oracle.sql"
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host
    user        = "opc"
    private_key = var.private_key
  }
}

  provisioner "file" {
    source      = "./modules/provisioner/adw_verify_customer_profile_oracle.sql"
    destination = "/home/opc/adw_verify_customer_profile_oracle.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

# databricks
  provisioner "file" {
    source      = "./modules/provisioner/atp_customer_analytics_kpi.sql"
    destination = "/home/opc/atp_customer_analytics_kpi.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/databricks-customer_analytics_kpi.sql"
    destination = "/home/opc/databricks-customer_analytics_kpi.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

provisioner "file" {
  source      = "${path.module}/adw_analytics_oracle_api.generated.sql"
  destination = "/home/opc/adw_analytics_oracle_api.sql"
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host
    user        = "opc"
    private_key = var.private_key
  }
}

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }

    inline = [
      "echo 'OCI user ocid length: ${length(local.effective_oci_user_ocid)}'",
      "echo 'OCI tenancy ocid length: ${length(local.effective_oci_tenancy_ocid)}'",
      "echo 'OCI fingerprint length: ${length(local.effective_oci_fingerprint)}'",
      "echo 'OCI private key length: ${length(local.effective_oci_private_key)}'",

      "sudo chmod 777 /tmp/file_envs.sh",
      "sudo chmod 777 /home/opc/fashion-retail-app-2026-02-10-11-53.zip",
      "sh /tmp/file_envs.sh",

      "sudo dnf -y install unzip python39 python39-pip firewalld oracle-instantclient-release-el8 oracle-instantclient-basic || sudo yum -y install unzip python39 python39-pip firewalld oracle-instantclient-basic",

      "sudo systemctl enable --now firewalld || true",
      "ZONE=$(sudo firewall-cmd --get-active-zones 2>/dev/null | head -n 1); if [ -z \"$ZONE\" ]; then ZONE=public; fi; echo \"Using firewalld zone: $ZONE\"",
      "sudo firewall-cmd --zone=$ZONE --permanent --add-port=5000/tcp || true",
      "sudo firewall-cmd --reload || true",

      "mkdir -p /home/opc/wallet_${var.db_name}",
      "unzip -o /home/opc/wallet_${var.db_name}.zip -d /home/opc/wallet_${var.db_name}",

      "cat > /home/opc/wallet_${var.db_name}/sqlnet.ora <<'EOF'\nWALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY=\"/home/opc/wallet_${var.db_name}\")))\nSSL_SERVER_DN_MATCH=yes\nEOF",

      "sudo rm -rf /home/opc/fashion-retail-app",
      "mkdir -p /home/opc/fashion-retail-app",
      "unzip -o /home/opc/fashion-retail-app-2026-02-10-11-53.zip -d /home/opc/fashion-retail-app",

      "APP_DIR=/home/opc/fashion-retail-app/fashion-retail-app",
      "echo \"APP_DIR=$APP_DIR\"",

      "cat > $APP_DIR/.env <<'EOF'\nDOCUMENT_BACKEND=${var.mongo_mode}\nDB_ENV=${local.app_db_env}\nMONGO_URI=${var.mongo_uri}\nMONGO_DBNAME=${var.mongo_db_name}\nORACLE_USER=cohub\nORACLE_PASSWORD=AaBbCcDdEe123#\nORACLE_DSN=${lower(var.db_name)}_tp\nORACLE_WALLET_LOCATION=/home/opc/wallet_${var.db_name}\nTNS_ADMIN=/home/opc/wallet_${var.db_name}\nEOF",

      "cat > /home/opc/sync_mongo_atp_to_adw.env <<'EOF'\nexport MONGO_URI='${var.mongo_uri}'\nexport MONGO_DBNAME='${var.mongo_db_name}'\nexport ORACLE_USER='cohub'\nexport ORACLE_PASSWORD='AaBbCcDdEe123#'\nexport ORACLE_DSN='${lower(var.db_name)}_tp'\nexport ORACLE_WALLET_LOCATION='/home/opc/wallet_${var.db_name}'\nEOF",

      "cd $APP_DIR && if [ -d flask_session ]; then mv flask_session flask_session_local_backup_$(date +%s); fi",
      "cd $APP_DIR && rm -rf venv",
      "cd $APP_DIR && python3.9 -m venv venv",
      "cd $APP_DIR && ./venv/bin/python -m pip install --upgrade pip",
      "cd $APP_DIR && ./venv/bin/python -m pip install 'Flask==2.0.3' 'Werkzeug==2.0.3' 'Flask-Session==0.4.0' 'pymongo[srv]==4.0.2' 'oracledb' 'python-dotenv' 'select_ai' 'Markdown' 'PyYAML'",

      "sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"ADMIN/${var.db_password}@${var.conn_db}\" @/home/opc/adw-co-hub-v0.01-admin-user.sql",
      "sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"ADMIN/${var.atp_db_password}@${var.conn_db_atp}\" @/home/opc/co_install.sql",
      "sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"CO/AaBbCcDdEe123#@${var.conn_db_atp}\" @/home/opc/co_create.sql",
      "sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"CO/AaBbCcDdEe123#@${var.conn_db_atp}\" @/home/opc/co_populate.sql",

      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Running ATP CO Mongo Setup ==='; sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"ADMIN/${var.atp_db_password}@${var.conn_db_atp}\" @/home/opc/atp-co-mongo-setup.sql; fi",

      "echo '=== Importing co-customer_profile.csv into Mongo-compatible backend ==='",
      "ls -lah /home/opc/co-customer_profile.csv",
      "if [ \"${var.mongo_mode}\" = \"atlas\" ] || [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then cd $APP_DIR && ./venv/bin/python - <<'PY'\nimport csv\nimport json\nfrom pymongo import MongoClient\n\nmongo_uri = '${var.mongo_uri}'\ndb_name = '${var.mongo_db_name}'\ncsv_file = '/home/opc/co-customer_profile.csv'\n\nprint('Connecting to Mongo-compatible backend...')\nclient = MongoClient(mongo_uri, serverSelectionTimeoutMS=10000, connectTimeoutMS=10000, retryWrites=False)\nclient.admin.command('ping')\ndb = client[db_name]\n\ncustomer_profile = db['customer_profile']\napp_users = db['app_users']\nshopping_cart = db['shopping_cart']\nchat_history = db['chat_history']\n\ncustomer_profile.drop()\napp_users.delete_many({})\nshopping_cart.delete_many({})\nchat_history.delete_many({})\n\ndocs = []\nusers = []\nseen_emails = set()\n\nwith open(csv_file, newline='', encoding='utf-8-sig') as f:\n    reader = csv.DictReader(f)\n    for row in reader:\n        if not row.get('DATA'):\n            continue\n\n        doc = json.loads(row['DATA'])\n        docs.append(doc)\n\n        customer_id = doc.get('customerId')\n        personal = doc.get('personalInfo', {}) or {}\n        email = personal.get('email')\n        full_name = personal.get('fullName')\n\n        if email and email not in seen_emails:\n            users.append({\n                'email': email,\n                'full_name': full_name or email,\n                'password': 'user',\n                'customer_id': customer_id,\n                'is_active': 'Y'\n            })\n            seen_emails.add(email)\n\nif docs:\n    customer_profile.insert_many(docs)\n    print(f'Inserted into customer_profile: {len(docs)}')\nelse:\n    print('No documents found in DATA column')\n\nif users:\n    app_users.insert_many(users)\n    print(f'Inserted into app_users from customer profiles: {len(users)}')\nelse:\n    print('No users generated from CSV')\n\napp_users.delete_many({'email': 'demo@demo.com'})\napp_users.insert_one({\n    'email': 'demo@demo.com',\n    'full_name': 'Demo User',\n    'password': 'demo',\n    'customer_id': 1,\n    'is_active': 'Y'\n})\nprint('Inserted demo user into app_users')\n\nshopping_cart.insert_one({'_bootstrap': True})\nshopping_cart.delete_one({'_bootstrap': True})\nchat_history.insert_one({'_bootstrap': True})\nchat_history.delete_one({'_bootstrap': True})\n\nprint('customer_profile count =', customer_profile.count_documents({}))\nprint('app_users count =', app_users.count_documents({}))\nprint('shopping_cart count =', shopping_cart.count_documents({}))\nprint('chat_history count =', chat_history.count_documents({}))\nprint('sample profile =', customer_profile.find_one({}, {'customerId': 1, 'personalInfo.email': 1, 'personalInfo.fullName': 1}))\nprint('sample app user =', app_users.find_one({}, {'email': 1, 'full_name': 1, 'customer_id': 1}))\nPY\nfi",

      "sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/cohub-create_tables_ddl.sql",
      "sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/cohub-product_catalog.sql",
      "sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/adw-co-hub-v0.01-cohub-user.sql",

      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Syncing Mongo ATP profiles into ADW ==='; set -a; . /home/opc/sync_mongo_atp_to_adw.env; set +a; /home/opc/fashion-retail-app/fashion-retail-app/venv/bin/python /home/opc/sync_mongo_atp_to_adw.py; fi",
      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Applying Oracle customer profile function ==='; sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/adw_customer_profile_function_oracle.sql; fi",
      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Applying Oracle AI profiles ==='; sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/adw_ai_profiles_oracle.sql; fi",

      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Creating ATP analytics table ==='; sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"CO/AaBbCcDdEe123#@${var.conn_db_atp}\" @/home/opc/atp_customer_analytics_kpi.sql; fi",
      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Loading ATP analytics data ==='; sql -cloudconfig /home/opc/wallet_${var.atp_db_name}.zip \"CO/AaBbCcDdEe123#@${var.conn_db_atp}\" @/home/opc/databricks-customer_analytics_kpi.sql; fi",
      "if [ \"${var.mongo_mode}\" = \"oracle_api\" ]; then echo '=== Wiring ADW analytics over atp_co_link ==='; sql -cloudconfig /home/opc/wallet_${var.db_name}.zip \"cohub/AaBbCcDdEe123#@${var.conn_db}\" @/home/opc/adw_analytics_oracle_api.sql; fi",

      "cd $APP_DIR && ./venv/bin/python db_connection.py",

      "sudo pkill -f 'app.py' || true",
      "cd $APP_DIR && nohup ./venv/bin/python -u ./app.py > app.log 2>&1 &",
      "sleep 3",
      "cd $APP_DIR && tail -n 200 app.log || true",

      "echo '=== Application deployment finished ==='",
      "echo 'You can now access the application in your browser.'",
      "echo 'URL: http://${var.host}:5000'",
      "echo 'Use one of the demo users populated from the database to sign in.'",
      "echo 'Example credentials:'",
      "echo '  Username: tammy.bryant@internalmail'",
      "echo '  Password: user'",
      "echo '=== Application is ready ==='"
    ]
  }
}