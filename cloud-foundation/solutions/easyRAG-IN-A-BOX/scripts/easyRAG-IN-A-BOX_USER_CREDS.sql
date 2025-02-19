----------------------------------------------------------------
--
-- easyRAG-IN-A-BOX.txt
--
-- this script will create the necesarry credentials set to 
-- populate and use the rag agent
--
----------------------------------------------------------------

----------------------------------------------------------------
-- AS DATABASE USER
----------------------------------------------------------------
----------------------------------------------------------------
-- Create USER_CREDS credentials for the DB USER
----------------------------------------------------------------
-- '&1' - ${var.apex_user}
-- "&2" - ${var.user_ocid}
-- "&3" - ${var.tenancy_ocid}
-- "&4" - ${var.bucket_url}   
-- "&5" - ${var.private_key}
-- "&6" - ${var.fingerprint}
-- "&7" - ${var.compartment_id}
----------------------------------------------------------------
-- Create user settings table
----------------------------------------------------------------

-- Insert data into the q_logs table
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

-- exercise the setting table
select * from eriab_user_settings;

-- Insert credentials data into the setting table
INSERT INTO eriab_user_settings VALUES (
    '&1',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
            "bucket_url"   :  "&4",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));


-- Insert credentials data into the setting table
INSERT INTO eriab_user_settings VALUES (
    '&1',
    'RAGCRED',
    json('{ "user_ocid"    :  "&2",
            "tenancy_ocid" :  "&3",
        "compartment_ocid" :  "&7",
            "private_key"  :  "&5",
            "fingerprint"  :  "&6"
          }'));


-- exercise the setting table
select * from eriab_user_settings;


begin
  eriab_create_bucket_cred('&1');
  eriab_create_llm_cred('&1');
  eriab_create_index('&1');
end;
/

--
-- end of script
--