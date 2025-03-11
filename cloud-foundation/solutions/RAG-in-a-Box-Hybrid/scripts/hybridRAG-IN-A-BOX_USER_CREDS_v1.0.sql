-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
----------------------------------------------------------------
--
-- hybridRAG-IN-A-BOX_USER_CREDS.sql
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
--
-- v1.0 mac initial release
--
----------------------------------------------------------------

----------------------------------------------------------------
-- AS DATABASE USER
----------------------------------------------------------------

-- Insert data into the settings table with sensible defaults
-- for all the three phases: chunking, index, search
--

INSERT INTO hriab_user_settings VALUES (
    '&1',
    'VECTOR',
    json('{ "vector_idxtype":  "HNSW",
            "distance"      :  "COSINE",
            "accuracy"      :  95,
            "model"         :  "HRIAB_IN_DB_LLM",
            "by"            :  "words",
            "max"           :  300,
            "overlap"       :  15,
            "normalize"     :  "all",
            "split"         :  "sentence",
            "memory"        :  10000000000,
            "parallel"      :  4
          }'));

INSERT INTO hriab_user_settings VALUES (
    '&1',
    'EXEC',
    json('{ "topk"          : 5,
            "penalty_t"     : 5,
            "penalty_v"     : 1,
            "weight_t"      : 1,
            "weight_v"      : 10
          }'));

INSERT INTO hriab_user_settings VALUES (
    '&1',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
            "bucket_url"   :  "&4",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));

INSERT INTO hriab_user_settings VALUES (
    '&1',
    'RAGCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
        "compartment_ocid" :  "&7",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));

-- exercise the setting table
select * from hriab_user_settings;

begin
  hriab_create_bucket_cred('&1');
  hriab_create_llm_cred('&1');
  hriab_populate_source('&1');
  -- hriab_create_index_ws('&1'); -- need to be done in the GUI
end;
/

--
-- end of script
--