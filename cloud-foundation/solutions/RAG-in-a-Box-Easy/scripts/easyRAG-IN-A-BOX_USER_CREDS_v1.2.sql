-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
----------------------------------------------------------------
--
-- easyRAG-IN-A-BOX_USER_CREDS.sql
--
-- this script will create the necessary credentials set, and
-- complete the initial setup for immediate use of RIAB
--
-- Parameters
--
-- '&1' - ${var.apex_user}
-- "&2" - ${var.user_ocid}
-- "&3" - ${var.tenancy_ocid}
-- "&4" - ${var.bucket_url}   
-- "&5" - ${var.private_key}
-- "&6" - ${var.fingerprint}
-- "&7" - ${var.compartment_id}
-- "&8" - ${var.llm_region}
--
-- v1.0 iop initial release
-- v1.1 mac update docs
-- v1.2 mac added variable 8 (llm region)
--
----------------------------------------------------------------

----------------------------------------------------------------
-- AS DATABASE USER
----------------------------------------------------------------


INSERT INTO eriab_user_settings VALUES (
    '&1',
    'VECTOR',
    json('{ "vecdim"   :  1024,
            "vecdim_m" :  "cosine",
            "chunk_o"  :  128,
            "chunk_s"  :  1024,
            "simth"    :  0,
            "match"    :  5,
            "refresh"  :  1040
          }'));

INSERT INTO eriab_user_settings VALUES (
    '&1',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
            "bucket_url"   :  "&4",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));

INSERT INTO eriab_user_settings VALUES (
    '&1',
    'RAGCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
        "compartment_ocid" :  "&7",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6",
            "llm_region"   :  "&8"
          }'));

-- exercise the setting table
select * from eriab_user_settings;

-- create bucket and llm credential, start ingestion and index creation
begin
  eriab_create_bucket_cred('&1');
  eriab_create_llm_cred('&1');
  eriab_create_index('&1');
end;
/

--
-- end of script
--