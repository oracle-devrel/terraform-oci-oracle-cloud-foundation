-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
----------------------------------------------------------------
--
-- vectorRAG-IN-A-BOX_USER_CREDS.sql
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

-- Insert data into the settings table with sensible defaults
-- for all the three phases: chunking, index, search
--
INSERT INTO vriab_user_settings VALUES (
    '&1',
    'CHUNKING',
    json('{
          "by"          : "words",
          "max"         : 300,
          "overlap"     : 15,
          "split"       : "sentence",
          "normalize"   : "options",
          "extend"      : "true"
          }'));

INSERT INTO vriab_user_settings VALUES (
    '&1',
    'VECTOR',
    json('{ "idxtype"  : "HNSW",
            "distance" : "COSINE",
            "accuracy" : 95,
            "neighbors": 50,
            "efconstr" : 1000,
            "samples"  : 1,
            "minvect"  : 0,
            "parallel" : 2
          }'));

INSERT INTO vriab_user_settings VALUES (
    '&1',
    'EXEC',
    json('{ "topk"     : 5,
            "distance" : "COSINE",
            "accuracy" : 95
          }'));

INSERT INTO vriab_user_settings VALUES (
    '&1',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
            "bucket_url"   :  "&4",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));

INSERT INTO vriab_user_settings VALUES (
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
select * from vriab_user_settings;

begin
  vriab_create_bucket_cred('&1');
  vriab_create_llm_cred('&1');
  vriab_process_input_files_ws('&1');
  -- vriab_create_index('&1'); -- need to be done in the GUI
end;
/

--
-- end of script
--