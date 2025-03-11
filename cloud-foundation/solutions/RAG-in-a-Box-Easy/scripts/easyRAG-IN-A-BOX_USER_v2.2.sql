-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
--------------------------------------------------------------------------------------------------------------------------------
--
-- easyRAG-IN-A-BOX_USER.sql
--
-- this script will setup up a new user in an autonomous DB
-- and create a RAG system loading from source documents on
-- object store and the select AI framework.
--
--
-- v1.0 mac initial release
-- v1.1 mac add credentials management
-- v1.2 mac add acl verification and drop table error suppression
-- v1.3 mac add match_limit parameter
-- v1.4 mac add custom error formatting
-- v1.5 mac add drop if exists command and exit line for terraform
-- v2.0 mac first production release
-- v2.1 mac swapped llama with cohere model for answer generation
-- v2.2 mac added eriab_util_timestamp_diff
--
-- Parameters
--
-- no parameters passed to this script
--
----------------------------------------------------------------

----------------------------------------------------------------
-- AS DATABASE USER
----------------------------------------------------------------

--
-- Verify ACLs
--
select * from USER_HOST_ACES;

----------------------------------------------------------------
-- Create user settings table
----------------------------------------------------------------

drop table if exists eriab_user_settings;

CREATE TABLE eriab_user_settings(
   riab_user VARCHAR2(128) NOT NULL,
   pref_type VARCHAR2(10)  NOT NULL,
   settings  JSON,
   CONSTRAINT eriab_user_settings_pk PRIMARY KEY (riab_user, pref_type)
);

-- Insert data into the q_logs table
INSERT INTO eriab_user_settings VALUES (
    'DEFAULT',
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
    'DEFAULT',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
            "bucket_url"   :  "<<replace with your bucket url>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>"
          }'));

-- Insert credentials data into the setting table
INSERT INTO eriab_user_settings VALUES (
    'DEFAULT',
    'RAGCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
        "compartment_ocid" :  "<<replace with your compartment ocid>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>"
          }'));

-- exercise the setting table
select * from eriab_user_settings;

----------------------------------------------------------------
-- Create the credentials for accessing the bucket with content
----------------------------------------------------------------

create or replace procedure eriab_create_bucket_cred( r_user IN VARCHAR2 )
is
  uocid  varchar2(256);
  tocid  varchar2(256);
  pkey   varchar2(2000);
  fprint varchar2(256);
begin
  -- clean up
  begin
    dbms_cloud.drop_credential(credential_name => 'ERIAB_RAG_BUCKET');
  exception
    when others then null;
  end;

-- get vector creation prefs
  select xuocid,
         xtocid,
         xpkey,
         xfprint
           into uocid,tocid,pkey,fprint
           from json_table(
            (select settings from eriab_user_settings
             where riab_user = r_user
               and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xuocid  varchar2(256) format json PATH '$.user_ocid',
              xtocid  varchar2(256) format json PATH '$.tenancy_ocid',
              xpkey   varchar2(2000) format json PATH '$.private_key',
              xfprint varchar2(256) format json PATH '$.fingerprint'));
/*
  dbms_output.put_line(SUBSTR(pkey, 2, LENGTH(pkey) - 2));
  dbms_output.put_line(SUBSTR(uocid, 2, LENGTH(uocid) - 2));
  dbms_output.put_line(SUBSTR(tocid, 2, LENGTH(tocid) - 2));
  dbms_output.put_line(SUBSTR(fprint, 2, LENGTH(fprint) - 2));
*/

  -- remove the quote marks left over from json storage otherwise the call will succeed
  -- but you'll get an auth violation
  DBMS_CLOUD.CREATE_CREDENTIAL (
    credential_name => 'ERIAB_RAG_BUCKET',
    user_ocid       => SUBSTR(uocid, 2, LENGTH(uocid) - 2),
    tenancy_ocid    => SUBSTR(tocid, 2, LENGTH(tocid) - 2),
    private_key     => SUBSTR(pkey, 2, LENGTH(pkey) - 2),
    fingerprint     => SUBSTR(fprint, 2, LENGTH(fprint) - 2)
  );

end;
/

/*
-- create the bucket credential
begin
  eriab_create_bucket_cred('DEFAULT');
end;
/
*/
----------------------------------------------------------------
-- Create the credentials for accessing the OCI GenAI LLM:
----------------------------------------------------------------
create or replace procedure eriab_create_llm_cred( r_user IN VARCHAR2 )
is
  uocid  varchar2(256);
  tocid  varchar2(256);
  cocid  varchar2(256);
  pkey   varchar2(2000);
  fprint varchar2(256);
  jo     json_object_t;
  bo     clob := ' ';
begin

  -- clean up
  begin
    dbms_CLOUD.drop_credential(credential_name => 'ERIAB_LLM_CRED');
  exception
    when others then null;
  end;

-- get vector creation prefs
  select xuocid,
         xtocid,
         xcocid,
         xpkey,
         xfprint
           into uocid,tocid,cocid,pkey,fprint
           from json_table(
            (select settings from eriab_user_settings
             where riab_user = r_user
               and pref_type = 'RAGCRED'
           ), '$[*]' COLUMNS (
              xuocid  varchar2(256) format json PATH '$.user_ocid',
              xtocid  varchar2(256) format json PATH '$.tenancy_ocid',
              xcocid  varchar2(256) format json PATH '$.compartment_ocid',
              xpkey   varchar2(2000) format json PATH '$.private_key',
              xfprint varchar2(256) format json PATH '$.fingerprint'));

-- credentials for GenAI OCI:
  dbms_lob.append(bo, '{ "user_ocid" : ');
  dbms_lob.append(bo, uocid);
  dbms_lob.append(bo, ', "tenancy_ocid" : ');
  dbms_lob.append(bo, tocid);
  dbms_lob.append(bo, ', "compartment_ocid" : ');
  dbms_lob.append(bo, cocid);
  dbms_lob.append(bo, ', "private_key" : ');
  dbms_lob.append(bo, pkey);
  dbms_lob.append(bo, ', "fingerprint" : ');
  dbms_lob.append(bo, fprint);
  dbms_lob.append(bo, '}');

  jo := json_object_t.parse(bo);

  dbms_vector.create_credential(
      credential_name   => 'ERIAB_LLM_CRED',
      params            => json(jo.to_string));

end;
/

/*
-- create the bucket credential
begin
  eriab_create_llm_cred('DEFAULT');
end;
/

-- Test that the LLM is working:
SELECT
    dbms_vector.utl_to_embedding(
        'hello',
        json('{
            "provider": "OCIGenAI",
            "credential_name": "ERIAB_LLM_CRED",
            "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
            "model": "cohere.embed-multilingual-v3.0"
        }')
    ) as TEST_EMBEDDING
FROM dual;
*/

--------------------------------------
-- create the vector index using the select ai framework
--------------------------------------
CREATE OR REPLACE PROCEDURE eriab_create_index (
  r_user IN VARCHAR2
) AUTHID DEFINER IS
  vd   number;
  vdm  varchar2(50);
  co   number;
  cs   number;
  rr   number;
  st   number;
  ml   number;
  bt   varchar2(512);
BEGIN

-- Clean-up
  DBMS_CLOUD_AI.drop_vector_index( index_name => 'ERIAB_VECTOR_INDEX', force => true);
  DBMS_CLOUD_AI.drop_profile( profile_name => 'ERIAB_PROFILE', force => true);

-- get vector creation prefs
  select to_number(vecdim),
         vecdim_m,
         to_number(refresh),
         to_number(chunk_o),
         to_number(chunk_s),
         to_number(match),
         to_number(simth)
           into vd,vdm,rr,co,cs,ml,st
           from json_table(
            (select settings from eriab_user_settings
             where riab_user = r_user
               and pref_type = 'VECTOR'
           ), '$[*]' COLUMNS (
              vecdim    varchar2(256) format json PATH '$.vecdim',
              vecdim_m  varchar2(256) format json PATH '$.vecdim_m',
              refresh   varchar2(256) format json PATH '$.refresh',
              chunk_o   varchar2(256) format json PATH '$.chunk_o',
              chunk_s   varchar2(256) format json PATH '$.chunk_s',
              match     varchar2(256) format json PATH '$.match',
              simth     varchar2(256) format json PATH '$.simth'));

-- get bucket url
  select xbt into bt
           from json_table(
            (select settings from eriab_user_settings
             where riab_user = r_user
               and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xbt varchar2(512) format json PATH '$.bucket_url'));

-- Create an AI profile used for natural language queries
  DBMS_CLOUD_AI.create_profile(
      'ERIAB_PROFILE',
      '{"provider": "oci",
        "credential_name": "ERIAB_LLM_CRED",
        "vector_index_name": "ERIAB_VECTOR_INDEX",
        "embedding_model": "cohere.embed-multilingual-v3.0",
        "model": "cohere.command-r-plus-08-2024",
        "oci_apiformat": "COHERE"
      }');

--        "model": "meta.llama-3.1-405b-instruct",
--        "oci_apiformat": "GENERIC"


-- Create the vector index and the pipeline.
  DBMS_CLOUD_AI.create_vector_index(
         index_name  => 'ERIAB_VECTOR_INDEX',
         attributes  => '{"vector_db_provider": "oracle",
                          "location": '|| bt ||',
                          "object_storage_credential_name": "ERIAB_RAG_BUCKET",
                          "profile_name": "ERIAB_PROFILE",
                          "vector_dimension": '||vd||',
                          "vector_distance_metric": '||vdm||',
                          "refresh_rate": '||rr||',
                          "chunk_overlap": '||co||',
                          "similarity_threshold": '||st||',
                          "match_limit": '||ml||',
                          "chunk_size": '||cs||'
      }');
end;
/

/*
-- create the index and the profile
begin
  eriab_create_index('DEFAULT');
end;
/

-- Check for errors
—— you need to set profile before you run SQL
exec DBMS_CLOUD_AI.set_profile('ERIAB_PROFILE');

-- doesn't work on DB ACTIONS!!
-- SELECT AI CHAT what is a data strategy;
SELECT DBMS_CLOUD_AI.GENERATE(prompt       => 'what is a data strategy?',
                              profile_name => 'ERIAB_PROFILE',
                              action       => 'narrate')
FROM dual;
*/

----------------------------------------------------------------
-- check status of infrastructure
----------------------------------------------------------------
CREATE OR REPLACE FUNCTION eriab_check_status
  RETURN number
is
  cnt number;
begin

  -- check credentials
  select count(*) into cnt from user_credentials
   where credential_name = 'ERIAB_LLM_CRED' or
         credential_name = 'ERIAB_RAG_BUCKET';

  -- 1 = credentials not ok
  if (cnt < 2) then
    return 1;
  end if;

  -- check index
  select count(*) into cnt from user_indexes
   where index_name = 'ERIAB_VECTOR_INDEX';

  -- 2 = index not present
  if (cnt = 0) then
    return 2;
  end if;

  -- all ok
  return 0;
end;
/


----------------------------------------------------------------
-- Get the error table for the current index
----------------------------------------------------------------

drop table if exists eriab_err_temp;

-- needed to get the pipeline errors (if any)
create table eriab_err_temp (
ID            NUMBER not null,                    
NAME          VARCHAR2(4000),
BYTES         NUMBER,
CHECKSUM      VARCHAR2(128),
LAST_MODIFIED TIMESTAMP(6) WITH TIME ZONE,
STATUS        VARCHAR2(30),
ERROR_CODE    NUMBER,
ERROR_MESSAGE VARCHAR2(4000),
START_TIME    TIMESTAMP(6) WITH TIME ZONE,
END_TIME      TIMESTAMP(6) WITH TIME ZONE,
SID           NUMBER,
SERIAL#       NUMBER,
ROWS_LOADED   NUMBER,
OPERATION_ID  NUMBER);

-- create the helping procedure
CREATE OR REPLACE PROCEDURE eriab_err_table (
   i_name IN  varchar2,
   t_name OUT varchar2
) IS
BEGIN
  begin
    with index_name_value as ( select i_name as index_name ),
         index_table_name as ( select INDEX_NAME, INDEX_TYPE, INDEX_SUBTYPE, TABLE_NAME, STATUS
                                 from USER_INDEXES 
                                where INDEX_NAME = (select index_name from index_name_value)),
         pipeline_name    as ( select status_table
                                 from user_cloud_pipelines
                                where pipeline_name = (select index_name from index_name_value) || '$VECPIPELINE')
    select status_table into t_name from pipeline_name;
    EXCEPTION
        when no_data_found
          then t_name := 'INVALID'; 
        WHEN OTHERS 
          THEN null;
        --dbms_output.put_line(SQLCODE);
  end;
end;
/

/*
-- test it
declare
  t varchar2(256);
BEGIN
    ERIAB_ERR_TABLE( 'ERIAB_VECTOR_INDEX', t);
    dbms_output.put_line(t);
end;
/
*/


----------------------------------------------------------------
-- Get the answer!
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE eriab_get_answer (
   user_question IN  CLOB,
   llm_answer    OUT CLOB,
   a_mode        IN  VARCHAR2
) IS
  a_temp  CLOB;
BEGIN

-- DBMS_OUTPUT.PUT_LINE('user_question: ' || user_question);

-- privilege violation in APEX if used, it doesn't make any sense as apex has sessionsless invocation
-- DBMS_CLOUD_AI.set_profile('eriab_profile');
-- SELECT AI NARRATE what is a data strategy
-- SELECT AI RUNSQL what is a data strategy

  if (upper(a_mode) = 'NARRATE') or (upper(a_mode) = 'RUNSQL') then
    begin
      SELECT DBMS_CLOUD_AI.GENERATE(prompt       => user_question,
                                    profile_name => 'ERIAB_PROFILE',
                                    action       => a_mode)
        INTO llm_answer FROM dual;
    exception
      when OTHERS THEN llm_answer := 'Your query returned with error '||SQLCODE;
    end;
  else
    llm_answer := to_clob('Wrong mode chosen, only narrate or runsql allowed.');
  end if;

END;
/

/*
-- exercise the routine
VAR aa CLOB;
begin
  -- read this question from the user
  eriab_get_answer( to_clob('Describe the value of data strategy'), :aa, 'narrate');

  DBMS_OUTPUT.PUT_LINE('Answer: ' || :aa);
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Calculates msecs between timestamps
--------------------------------------------------------------------------------------------------------------------------------
create or replace function eriab_util_timestamp_diff (
  start_time in timestamp,
    end_time in timestamp
) return number
is
  l_days    number;
  l_hours   number;
  l_minutes number;
  l_seconds number;
  l_milliseconds number;
begin
  select extract(day    from end_time - start_time )
       , extract(hour   from end_time - start_time )
       , extract(minute from end_time - start_time )
       , extract(second from end_time - start_time )
    into l_days, l_hours, l_minutes, l_seconds
    from dual;
    l_milliseconds := l_seconds*1000 + l_minutes*60*1000 + l_hours*60*60*1000 + l_days*24*60*60*1000;
    return int(l_milliseconds);
end;
/

/*
begin
  dbms_output.put_line(vriab_util_timestamp_diff(TO_TIMESTAMP('12.04.2017 23:59:59.999', 'DD.MM.YYYY HH24:MI:SS.FF3'), 
                                                 TO_TIMESTAMP('13.04.2017 00:00:00.001', 'DD.MM.YYYY HH24:MI:SS.FF3')));
end;
/
*/

----------------------------------------------------------------
-- Nice formatting for application errors only
-- register in "edit application definitions" -> error handling
----------------------------------------------------------------
create or replace function eriab_apex_error_handling (
    p_error in apex_error.t_error )
    return apex_error.t_error_result
is
    l_result          apex_error.t_error_result;
    l_reference_id    number;
    l_constraint_name varchar2(255);
begin
    l_result := apex_error.init_error_result (
                    p_error => p_error );

    -- Always show the error as inline error
    -- Note: If you have created manual tabular forms (using the package
    --       apex_item/htmldb_item in the SQL statement) you should still
    --       use "On error page" on that pages to avoid loosing entered data
    l_result.display_location := case
                                    when l_result.display_location = apex_error.c_on_error_page then apex_error.c_inline_in_notification
                                    else l_result.display_location
                                    end;

    
    -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
    -- then display the actual error text and not the full error stack with all the ORA error numbers.
    if p_error.ora_sqlcode BETWEEN -20999 AND -20000 then
        l_result.message := apex_error.get_first_ora_error_text (
                                p_error => p_error );
    end if;

    return l_result;
end eriab_apex_error_handling;

--
-- end of script
--