-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
--------------------------------------------------------------------------------------------------------------------------------
--
-- hybridRAG-IN-A-BOX_USER.sql
--
-- this script will setup up a new user in an autonomous DB
-- and create a RAG system loading from source documents on
-- object store and uses hybrid vector indexes.
--
-- v2.0 mac hybrid initial prod release
-- v2.1 mac fixed prefs
-- v2.2 mac fixed small errors
-- v2.3 mac added support for llm region
--
-- Parameters
--
-- no parameters passed to this script
--
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
-- AS DATABASE USER
----------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Create user settings table
--------------------------------------------------------------------------------------------------------------------------------

drop table if exists hriab_user_settings;

CREATE TABLE hriab_user_settings(
   riab_user VARCHAR2(128) NOT NULL,
   pref_type VARCHAR2(10)  NOT NULL,
   settings  JSON,
   CONSTRAINT vriab_user_settings_pk PRIMARY KEY (riab_user, pref_type)
);

-- Insert data into the settings table with sensible defaults
-- for all the three phases: chunking, index, search
--

-- Insert data into the q_logs table
INSERT INTO hriab_user_settings VALUES (
    'DEFAULT',
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
    'DEFAULT',
    'EXEC',
    json('{ "topk"          : 5,
            "penalty_t"     : 5,
            "penalty_v"     : 1,
            "weight_t"      : 1,
            "weight_v"      : 10
          }'));


-- Insert credentials data into the setting table
INSERT INTO hriab_user_settings VALUES (
    'DEFAULT',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
            "bucket_url"   :  "<<replace with your bucket url>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>"
          }'));

-- Insert credentials data into the setting table
INSERT INTO hriab_user_settings VALUES (
    'DEFAULT',
    'RAGCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
        "compartment_ocid" :  "<<replace with your compartment ocid>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>",
            "llm_region"   :  "<<replace with your llm region name>>"
          }'));

-- exercise the setting table
select * from hriab_user_settings;

--------------------------------------------------------------------------------------------------------------------------------
-- Create the credentials for accessing the bucket with content
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_create_bucket_cred (
  r_user IN VARCHAR2
) is
  uocid  varchar2(256);
  tocid  varchar2(256);
  pkey   varchar2(2000);
  fprint varchar2(256);
begin
  -- clean up
  begin
    dbms_cloud.drop_credential(credential_name => 'HRIAB_RAG_BUCKET');
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
            (select settings from hriab_user_settings
             where riab_user = r_user
               and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xuocid  varchar2(256) format json PATH '$.user_ocid',
              xtocid  varchar2(256) format json PATH '$.tenancy_ocid',
              xpkey   varchar2(2000) format json PATH '$.private_key',
              xfprint varchar2(256) format json PATH '$.fingerprint'));

  -- remove the quote marks left over from json storage otherwise the call will succeed
  -- but you'll get an auth violation
  DBMS_CLOUD.CREATE_CREDENTIAL (
    credential_name => 'HRIAB_RAG_BUCKET',
    user_ocid       => SUBSTR(uocid, 2, LENGTH(uocid) - 2),
    tenancy_ocid    => SUBSTR(tocid, 2, LENGTH(tocid) - 2),
    private_key     => SUBSTR(pkey, 2, LENGTH(pkey) - 2),
    fingerprint     => SUBSTR(fprint, 2, LENGTH(fprint) - 2)
  );

end hriab_create_bucket_cred;
/

/*
-- create the bucket credential
begin
  hriab_create_bucket_cred('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Create the credentials for accessing the OCI GenAI LLM:
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_create_llm_cred (
  r_user in varchar2
) is
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
    dbms_CLOUD.drop_credential(credential_name => 'HRIAB_LLM_CRED');
  exception
    when others then null;
  end;

-- get LLM prefs
  select xuocid,
         xtocid,
         xcocid,
         xpkey,
         xfprint
           into uocid,tocid,cocid,pkey,fprint
           from json_table(
            (select settings from hriab_user_settings
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
      credential_name   => 'HRIAB_LLM_CRED',
      params            => json(jo.to_string));

end hriab_create_llm_cred;
/

/*
-- create the bucket credential
begin
  hriab_create_llm_cred('DEFAULT');
end;
/

-- Test that the LLM is working:
SELECT
    dbms_vector.utl_to_embedding(
        'hello',
        json('{
            "provider": "OCIGenAI",
            "credential_name": "HRIAB_LLM_CRED",
            "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
            "model": "cohere.embed-multilingual-v3.0"
        }')
    ) as TEST_EMBEDDING
FROM dual;
*/


--------------------------------------------------------------------------------------------------------------------------------
-- Load ONNX model in the DB (a must for hybrid indexes)
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_load_onnx_model
is
begin
  -- clean up
  begin
    dbms_vector.drop_onnx_model(model_name => 'HRIAB_IN_DB_LLM');
  exception
    when others then null;
  end;

  -- since the source is a public url no credentials needed, so it can be called at sw load time
  dbms_vector.LOAD_ONNX_MODEL_CLOUD(
    model_name => 'HRIAB_IN_DB_LLM',
    credential => null, 
    uri => 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx',
    metadata => JSON('{
      "function"        : "embedding",
      "embeddingOutput" : "embedding" ,
      "input": { "input": ["DATA"]}
    }')
  );
end hriab_load_onnx_model;
/

-- this must be done once at the creation of the system
-- Load the model from the very beginning
begin
  hriab_load_onnx_model();
end;
/

select model_name, attribute_name, attribute_type, data_type, vector_info
  from user_mining_model_attributes
 where model_name = 'HRIAB_IN_DB_LLM'
 order by attribute_name;

SELECT dbms_vector.utl_to_embedding(
        'hello',
        json('{
           "provider" : "database", 
           "model"    : "HRIAB_IN_DB_LLM" 
        }')
    ) as onnx_embed_test_1
FROM dual;

SELECT VECTOR_EMBEDDING(HRIAB_IN_DB_LLM USING 'The quick brown fox jumps over the lazy dog 0123456789' as DATA) AS onnx_embed_test_2;

--------------------------------------------------------------------------------------------------------------------------------
-- Check status of infrastructure
--------------------------------------------------------------------------------------------------------------------------------

create or replace function hriab_check_status (
   r_user in varchar2
) return number
is
  cnt number;
begin

  -- check credentials
  select count(*) into cnt from user_credentials
   where credential_name = 'HRIAB_LLM_CRED' or
         credential_name = 'HRIAB_RAG_BUCKET';

  -- 1 = credentials not ok
  if (cnt < 2) then
    return 1;
  end if;

  -- check prefs
  select count(*) into cnt from hriab_user_settings
              where riab_user = r_user
                and pref_type = 'VECTOR' or
                    pref_type = 'EXEC';

  -- 2 = prefs not ok
  if (cnt < 2) then
    return 2;
  end if;

  -- check index
  select count(*) into cnt from user_indexes
   where index_name = 'HRIAB_HYBRID_INDEX';

  -- 3 = index not present
  if (cnt = 0) then
    return 3;
  end if;

  -- all ok
  return 0;

end hriab_check_status;
/

/*
begin
 dbms_output.put_line(hriab_check_status('DEFAULT'));
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- create the working tables for storing the chunks and the vectors
--------------------------------------------------------------------------------------------------------------------------------

-- clean up
drop table if exists hriab_doc_sources;

-- create the source URLs' directory
create table hriab_doc_sources(
    id           number generated by default as identity (increment by 1),
    url          varchar(500),
    to_be_purged varchar2(1));

-- working table for showing the status
create global temporary table hriab_ptt (rid rowid, note varchar2(500)) ON COMMIT DELETE ROWS;


--------------------------------------------------------------------------------------------------------------------------------
-- Load the files to be processed into the hybrid vector input table
-- reloading the table will drop the index!!!!
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_populate_source (
   r_user in varchar2
) is
  bt varchar2(512);
begin

  -- reloading the table will drop the index!!!!
  execute immediate 'drop index if exists hriab_hybrid_index force';
  execute immediate 'truncate table hriab_doc_sources';

  -- get bucket url
  select SUBSTR(xbt, 2, LENGTH(xbt) - 2) into bt
           from json_table(
            (select settings from hriab_user_settings
              where riab_user = r_user
                and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xbt varchar2(512) format json PATH '$.bucket_url'));

  for i in (select bt || '/' ||object_name obj_name from dbms_cloud.list_objects('HRIAB_RAG_BUCKET', bt)
  ) loop
    insert into hriab_doc_sources values (DEFAULT, i.obj_name, 'N');
  end loop;

  commit;

end hriab_populate_source;
/

/*
-- populate the table
begin
  hriab_populate_source('DEFAULT');
end;
/

select * from riab_doc_sources;

*/

--------------------------------------------------------------------------------------------------------------------------------
-- Update the source table with new files / removing the old ones / etc but preserving the rowid of the files already processed!
-- To be called if the files in the object store change
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_update_source (
   r_user in varchar2
) is
  counter number;
  bt      varchar2(512);
begin

  -- get bucket url
  select SUBSTR(xbt, 2, LENGTH(xbt) - 2) into bt
           from json_table(
            (select settings from hriab_user_settings
              where riab_user = r_user
                and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xbt varchar2(512) format json PATH '$.bucket_url'));

  -- default is to delete all rows not cleared
  update hriab_doc_sources
    set to_be_purged = 'Y';

  for i in (select bt || '/' ||object_name obj_name from dbms_cloud.list_objects('HRIAB_RAG_BUCKET', bt)
  ) loop

    select count(url) into counter
      from hriab_doc_sources
     where url = i.obj_name;
   
    if (counter = 0) then
      -- new file found
      insert into hriab_doc_sources values (DEFAULT, i.obj_name, 'N');
    else
      -- existing file already processed
      update hriab_doc_sources
         set to_be_purged = 'N'
       where url = i.obj_name;
    end if;
  end loop;

 -- clear the dead entries
  delete from hriab_doc_sources where to_be_purged = 'Y';
  commit;

end hriab_update_source;
/

/*
-- update the table
begin
  hriab_update_source('DEFAULT');
end;
/

-- verify URLs
select * from hriab_doc_sources;

*/

--------------------------------------------------------------------------------------------------------------------------------
-- create the prefs for the hybrid source
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_create_prefs (
    r_user in varchar2
) is
  s_temp JSON;
begin

  -- clean up
  begin
    dbms_vector_chain.drop_preference('hriab_vectorizer_pref');
              ctx_ddl.drop_preference('hriab_datastore');
    exception 
      when others 
        then null;
  end;

  -- get the embedding prefs
  select JSON_OBJECT(
           'vector_idxtype' VALUE t.settings."vector_idxtype",
           'distance'  VALUE t.settings."distance",
           'accuracy'  VALUE t.settings."accuracy",
           'model'     VALUE t.settings."model",
           'by'        VALUE t.settings."by",
           'max'       VALUE t.settings."max",
           'overlap'   VALUE t.settings."overlap",
           'normalize' VALUE t.settings."normalize",
           'split'     VALUE t.settings."split"
         ) into s_temp
    from hriab_user_settings t
   where riab_user = r_user
     and pref_type = 'VECTOR';

   if (JSON_VALUE(s_temp, '$.normalize') = 'options') then
     -- fix the normalize if options is selected
     select JSON_TRANSFORM( s_temp, insert '$.norm_options' = JSON('["punctuation","whitespace"]'))into s_temp FROM dual;
   end if;
   -- add security measure
   select JSON_TRANSFORM(s_temp,insert '$.extended' = 'true') into s_temp FROM dual;

  -- ... create the chunking preferences ...
  dbms_vector_chain.create_preference('hriab_vectorizer_pref',
     dbms_vector_chain.vectorizer,
    s_temp
  );

  -- ... and define how to access the source url
  CTX_DDL.CREATE_PREFERENCE('hriab_datastore', 'NETWORK_DATASTORE');
      ctx_ddl.set_attribute('hriab_datastore', 'Timeout',   '60');   -- The default value is 30 seconds. The minimum value is 1 second and the maximum value is 3600 seconds.
      ctx_ddl.set_attribute('hriab_datastore', 'MAXTHREADS','120');  -- undocumented
      ctx_ddl.set_attribute('hriab_datastore', 'URLSIZE',   '1000'); -- undocumented
      ctx_ddl.set_attribute('hriab_datastore', 'MAXDOCSIZE','2000000000'); -- 2gb -- undocumented

end hriab_create_prefs;
/

/*
-- create the settings
begin
  hriab_create_prefs('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Create the hybrid index 
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_create_index (
  r_user in varchar2
) is
  me   number;
  pa   number;
begin

-- Clean-up
  execute immediate 'drop index if exists hriab_hybrid_index force';

-- get vector creation prefs
  select to_number(mex),
         to_number(pax)
           into me,pa
           from json_table(
            (select settings from hriab_user_settings
             where riab_user = r_user
               and pref_type = 'VECTOR'
           ), '$[*]' COLUMNS (
              mex  varchar2(256) format json PATH '$.memory',
              pax  varchar2(256) format json PATH '$.parallel'));

  execute immediate 'CREATE HYBRID VECTOR INDEX HRIAB_HYBRID_INDEX '||
                     ' on hriab_doc_sources(url) '||
                     ' parameters( ''vectorizer hriab_vectorizer_pref '||
                     '  datastore hriab_datastore ' ||
                     '  memory   ' ||me||
                     '  filter    ctxsys.auto_filter'' '||
                     ' ) parallel ' ||pa;

end hriab_create_index; 
/

/*
-- create the index
begin
  hriab_create_index('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- use the scheduler to call the above proc to create hybrid vector index. (ws = with scheduler)
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_create_index_ws  (
  r_user in varchar2
) is
begin

  -- clean up
  begin
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'HRIAB_CREATE_INDEX_JOB',
        force    => true);
    EXCEPTION when others then null;
  end;

  begin
    DBMS_SCHEDULER.DROP_PROGRAM (
      program_name  => 'HRIAB_CREATE_INDEX_PROG',
             force  => true);
    EXCEPTION when others then null;
  end;

  DBMS_SCHEDULER.CREATE_PROGRAM (
    program_name      => 'HRIAB_CREATE_INDEX_PROG',
    program_action    => 'hriab_create_index',
    program_type      => 'STORED_PROCEDURE',
    number_of_arguments => 1,
    enabled => false);

  DBMS_SCHEDULER.define_program_argument(
   program_name      => 'HRIAB_CREATE_INDEX_PROG',
   argument_position => 1,
   argument_name     => 'R_USER',
   argument_type     => 'VARCHAR2');

  DBMS_SCHEDULER.enable(name => 'HRIAB_CREATE_INDEX_PROG');

  -- run immediately
  DBMS_SCHEDULER.CREATE_JOB (
    job_name => 'HRIAB_CREATE_INDEX_JOB',
    program_name => 'HRIAB_CREATE_INDEX_PROG',
    enabled => false);

  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
   job_name => 'HRIAB_CREATE_INDEX_JOB',
   argument_position  => 1,
   argument_value => r_user);

  DBMS_SCHEDULER.enable(name => 'HRIAB_CREATE_INDEX_JOB');


end hriab_create_index_ws;
/

/*
-- Check for errors
SELECT err_timestamp, err_text
  FROM ctx_user_index_errors
  ORDER BY err_timestamp DESC;

select idx_status from ctx_user_indexes;
select * from ctx_user_index_errors;
*/

--------------------------------------------------------------------------------------------------------------------------------
-- deliver the chunking and the create index syntax from the prefs. It duplicates some code (bad) but it
-- formats the output nicely, so worth duplicating.
--------------------------------------------------------------------------------------------------------------------------------

create or replace function hriab_create_index_code (
  r_user in varchar2
) return clob is
  s_temp json;

  me   number;
  pa   number;

  cc   clob;
  ch   clob;
begin

  -- since the call to create the prefs takes a json input, I will not recreate the json on the fly, I will just
  -- get the prefs as such and add/fix stuff using json_transform()

  -- get the embedding prefs
  select JSON_OBJECT(
           'vector_idxtype' VALUE t.settings."vector_idxtype",
           'distance'  VALUE t.settings."distance",
           'accuracy'  VALUE t.settings."accuracy",
           'model'     VALUE t.settings."model",
           'by'        VALUE t.settings."by",
           'max'       VALUE t.settings."max",
           'overlap'   VALUE t.settings."overlap",
           'normalize' VALUE t.settings."normalize",
           'split'     VALUE t.settings."split"
         ) into s_temp
    from hriab_user_settings t
   where riab_user = r_user
     and pref_type = 'VECTOR';

   if (JSON_VALUE(s_temp, '$.normalize') = 'options') then
     -- fix the normalize if options is selected
     select JSON_TRANSFORM( s_temp, insert '$.norm_options' = JSON('["punctuation","whitespace"]'))into s_temp FROM dual;
   end if;
   -- add security measure
   select JSON_TRANSFORM(s_temp,insert '$.extended' = 'true') into s_temp FROM dual;

  -- ... create the chunking preferences ...
  ch := 'dbms_vector_chain.create_preference(''hriab_vectorizer_pref'',' ||chr(10)||
        '   dbms_vector_chain.vectorizer, ' ||chr(10)||
        json_serialize(s_temp pretty) || ' );';

  -- get vector creation prefs
  select to_number(mex),
         to_number(pax)
           into me,pa
           from json_table(
            (select settings from hriab_user_settings
             where riab_user = r_user
               and pref_type = 'VECTOR'
           ), '$[*]' COLUMNS (
              mex  varchar2(256) format json PATH '$.memory',
              pax  varchar2(256) format json PATH '$.parallel'));

  cc := 'CREATE HYBRID VECTOR INDEX HRIAB_HYBRID_INDEX '||chr(10)||
                     ' on hriab_doc_sources(url) '||chr(10)||
                     ' parameters( ''vectorizer hriab_vectorizer_pref '||chr(10)||
                     '              datastore  hriab_datastore ' ||chr(10)||
                     '              memory     ' ||me||chr(10)||
                     '              filter     ctxsys.auto_filter'' '||chr(10)||
                     '           ) parallel ' ||pa;

  cc := 'Chunking Prefs' || chr(10) || '---------------------------------------------' || chr(10) ||
           ch || chr(10) || chr(10) || '---------------------------------------------' || chr(10) ||
     'Create Index Code' || chr(10) || '---------------------------------------------' || chr(10) ||
           cc || chr(10)            || '---------------------------------------------' ;

  return cc;
end hriab_create_index_code; 
/


/*
-- test
declare
  cc clob;
begin
  cc := hriab_create_index_code('DEFAULT');
  dbms_output.put_line(cc);
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Create the "contains" string from the user question
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_gen_tokens (
   user_question IN  CLOB,
   user_tokens   OUT varchar2,
   rag_user      IN  VARCHAR2
) is
  prompt CLOB;
  t_tok  varchar2(512);
  llmreg varchar2(512);
begin

  prompt := 'isolate tokens and remove punctuation, articles, verbs, prepositions, etc. from the following string -'
            || user_question ||
            '-, return a list separated by the word "AND" prefixed with "S@@" and postfixed by "@@E"';

-- get llm region
  select SUBSTR(xllmreg, 2, LENGTH(xllmreg) - 2) into llmreg
           from json_table(
            (select settings from hriab_user_settings
             where riab_user = rag_user
               and pref_type = 'RAGCRED'
           ), '$[*]' COLUMNS (
              xllmreg varchar2(256) format json PATH '$.llm_region'));

  select dbms_vector_chain.utl_to_generate_text(
            prompt,
            json('{
     "provider"       : "ocigenai",
     "credential_name": "HRIAB_LLM_CRED",
     "url"            : "https://inference.generativeai.'||llmreg||'.oci.oraclecloud.com/20231130/actions/chat",
     "model"          : "cohere.command-r-plus-08-2024",
     "chatRequest"    : {
                      "maxTokens": 50,
                      "temperature": 0
                        }
   }')) into t_tok
   from dual;

   -- DBMS_OUTPUT.PUT_LINE('Postprocessed prompt: ' || t_tok);

   -- get only the words and disregard whatever the llm wraps it into...
   SELECT REGEXP_SUBSTR(t_tok, 'S@@([^@]+)@@E', 1, 1, NULL, 1) INTO user_tokens 
     FROM DUAL;

   -- user_tokens := user_question || '%%' || user_tokens;

end hriab_gen_tokens;
/

/*
-- exercise the routine
VAR aa CLOB;
begin
  hriab_gen_tokens( to_clob('Describe the value of data strategy'), :aa, 'DEFAULT');
  DBMS_OUTPUT.PUT_LINE('tokens: ' || :aa);
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Get the answer!
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure hriab_get_answer (
   user_question IN  varchar2,
   user_tokens   IN  varchar2,
   rag_user      IN  VARCHAR2,
   llm_answer    OUT CLOB,    -- new answer
   rag_context   IN OUT CLOB  -- in input brings in the cumulated previous answers to augment the context
                              -- in output shows the inner workings 
) is
  prompt  CLOB;
  context CLOB;
  sources CLOB;
  a_type  varchar2(50);
  llmreg  varchar2(512);
  a_temp  CLOB;
  a_json  CLOB;
  q_json  JSON;
  tk      NUMBER;
  pt      NUMBER;
  pv      NUMBER;
  wt      NUMBER;
  wv      NUMBER;

  rowids SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();
begin

  -- DBMS_OUTPUT.PUT_LINE('user_question: ' || user_question);
  -- DBMS_OUTPUT.PUT_LINE('user_tokens: ' || user_tokens);

  -- initialize the concatenated string
  context     := rag_context;
  prompt      := '';
  rowids.extend; -- need just one value

  -- get llm region
  select SUBSTR(xllmreg, 2, LENGTH(xllmreg) - 2) into llmreg
           from json_table(
            (select settings from hriab_user_settings
             where riab_user = rag_user
               and pref_type = 'RAGCRED'
           ), '$[*]' COLUMNS (
              xllmreg varchar2(256) format json PATH '$.llm_region'));

  -- get query prefs
  select to_number(topk),
       to_number(penalty_t),
       to_number(penalty_v),
       to_number(weight_t),
       to_number(weight_v)
           into tk,pt,pv,wt,wv
           from json_table(
            (select settings from hriab_user_settings
             where riab_user = rag_user
               and pref_type = 'EXEC'
           ), '$[*]' COLUMNS (
              topk      varchar2(256) format json PATH '$.topk',
              penalty_t varchar2(256) format json PATH '$.penalty_t',
              penalty_v varchar2(256) format json PATH '$.penalty_v',
              weight_t  varchar2(256) format json PATH '$.weight_t',
              weight_v  varchar2(256) format json PATH '$.weight_v'));

  if ((user_tokens is null) or (user_tokens = '')) then
    -- semantic only search
    a_type := 'vector';

    q_json := json(
           '{ "hybrid_index_name" : "hriab_hybrid_index",
              "vector":
               {
                       "search_text"   : "'||user_question||'",
                  "search_mode"   : "CHUNK",
               },
              "return":
               {
                  "values"        : [ "rowid", "score", "chunk_text", "chunk_id" ],
                  "topN"          : '||tk||'
               }
             }');
    select json_serialize(DBMS_HYBRID_VECTOR.SEARCH( q_json )
      returning clob pretty)
      into a_json
      from dual;

    FOR rec IN (
         select mrowid, mchunk_id, mchunk_text, to_number(mscore) as tscore
           from json_table( a_json, '$[*]' COLUMNS (
              mrowid      VARCHAR2(256) format json PATH '$.rowid',
              mchunk_id   VARCHAR2(256) format json PATH '$.chunk_id',
              mchunk_text CLOB          format json PATH '$.chunk_text',
              mscore      varchar2(256) format json PATH '$.score')
       )
    )
    LOOP

      -- get the rowid of the source file
      rowids(rowids.last) := SUBSTR(rec.mrowid, 2, LENGTH(rec.mrowid) - 2);
      select distinct url into sources from HRIAB_DOC_SOURCES
       where rowid in ( select * from table(rowids));

      -- add url to chunk
      context := context || ' ' || rec.mchunk_text || ' URL: ' || sources;

    END LOOP;

   -- text only search
  elsif ((user_question is null) or (user_question = '')) then
    a_type := 'text';

    q_json := json(
            '{ "hybrid_index_name" : "hriab_hybrid_index",
               "text":
                {
                  "contains"      : "'||user_tokens||'",
                },
               "return":
                {
                  "values"        : [ "rowid", "score" ],
                  "topN"          : '||tk||'
                }
             }');
    select json_serialize( DBMS_HYBRID_VECTOR.SEARCH( q_json ) returning clob pretty) into a_json from dual;

    FOR rec IN (
         select mrowid, mchunk_id, mchunk_text, to_number(mscore) as tscore
           from json_table(a_json, '$[*]' COLUMNS (
              mrowid      VARCHAR2(256) format json PATH '$.rowid',
              mchunk_id   VARCHAR2(256) format json PATH '$.chunk_id',
              mchunk_text CLOB          format json PATH '$.chunk_text',
              mscore      varchar2(256) format json PATH '$.score')
      )
    )
    LOOP
      -- get the rowid of the source file
      rowids(rowids.last) := SUBSTR(rec.mrowid, 2, LENGTH(rec.mrowid) - 2);
      select distinct url into sources from HRIAB_DOC_SOURCES
       where rowid in ( select * from table(rowids));

      -- add url to chunk
      context := context || ' ' || rec.mchunk_text || ' URL: ' || sources;
    END LOOP;

   -- semantic and text search
  else
    a_type := 'both';

    q_json := json(
           '{
              "hybrid_index_name" : "hriab_hybrid_index",
              "search_scorer"     : "rsf",
              "search_fusion"     : "UNION",
              "vector":
               {
                  "search_text"   : "'||user_question||'",
                  "search_mode"   : "CHUNK",
                  "score_weight"  : '||wv||',
                  "rank_penalty"  : '||pv||'
               },
              "text":
               {
                  "contains"      : "'||user_tokens||'",
                  "score_weight"  : '||wt||',
                  "rank_penalty"  : '||pt||'
                },
              "return":
               {
                  "values"        : [ "rowid", "chunk_id", "score", "vector_score", "text_score", "chunk_text" ],
                  "topN"          : '||tk||'
               }
             }');
    select json_serialize( DBMS_HYBRID_VECTOR.SEARCH( q_json ) returning clob pretty) into a_json from dual;

    FOR rec IN (
         select mrowid, mchunk_id, mchunk_text, to_number(mscore) as tscore
           from json_table(a_json, '$[*]' COLUMNS (
              mrowid      VARCHAR2(256) format json PATH '$.rowid',
              mchunk_id   VARCHAR2(256) format json PATH '$.chunk_id',
              mchunk_text CLOB          format json PATH '$.chunk_text',
              mscore      varchar2(256) format json PATH '$.score')
      )
    )
    LOOP
      -- get the rowid of the source file
      rowids(rowids.last) := SUBSTR(rec.mrowid, 2, LENGTH(rec.mrowid) - 2);
      select distinct url into sources from HRIAB_DOC_SOURCES
       where rowid in ( select * from table(rowids));

      -- add url to chunk
      context := context || ' ' || rec.mchunk_text || ' URL: ' || sources;
    END LOOP;

  end if;

  -- strip some of the annoying html tags
  select REGEXP_REPLACE(context, '<.+?>') as t into context from dual;
  
  -- DBMS_OUTPUT.PUT_LINE('Generated context: ' || context);

  -- concatenate strings and format it as an enhanced prompt to the LLM
  prompt := 'Answer the following question using the supplied context assuming you are a subject matter expert; include found URLs in a separated category labeled Sources. Question: '
                || user_question || ' Context: ' || rag_context ||' '|| context;

  -- overwrite the passed in context with the locally generated one
  rag_context := '-----Query----' || chr(10) || json_serialize(q_json) || chr(10) || '++++Chunks++++' || chr(10) || a_json || chr(10) || '****Context**** '|| chr(10) || context;

  select dbms_vector_chain.utl_to_generate_text(
            prompt, json('{
     "provider"       : "ocigenai",
     "credential_name": "HRIAB_LLM_CRED",
     "url"            : "https://inference.generativeai.'||llmreg||'.oci.oraclecloud.com/20231130/actions/chat",
     "model"          : "cohere.command-r-plus-08-2024",
     "chatRequest"    : { "maxTokens": 2048 }
   }')) into llm_answer
   from dual;

end hriab_get_answer;
/

/*
-- exercise the routine
VAR aa CLOB;
VAR bb CLOB;
begin
  -- read this question from the user
  hriab_get_answer( 'Describe the value of data strategy'), null, 'DEFAULT', :aa, :bb);

  DBMS_OUTPUT.PUT_LINE('Answer: ' || :aa);
end;
/

-- exercise the routine
VAR aa CLOB;
VAR bb CLOB;
begin
  -- read this question from the user
  hriab_get_answer( null, 'data AND strategy', 'DEFAULT', :aa, :bb);

  DBMS_OUTPUT.PUT_LINE('Answer: ' || :aa);
end;
/

-- exercise the routine
VAR aa CLOB;
VAR bb CLOB;
begin
  -- read this question from the user
  hriab_get_answer( 'Describe the value of data strategy', 'data AND strategy', 'DEFAULT', :aa, :bb);

  DBMS_OUTPUT.PUT_LINE('Answer: ' || :aa);
end;
/

*/
--------------------------------------------------------------------------------------------------------------------------------
-- Calculates msecs between timestamps
--------------------------------------------------------------------------------------------------------------------------------

create or replace function hriab_util_timestamp_diff (
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

end hriab_util_timestamp_diff;
/

/*
begin
  dbms_output.put_line(hriab_util_timestamp_diff(TO_TIMESTAMP('12.04.2017 23:59:59.999', 'DD.MM.YYYY HH24:MI:SS.FF3'), 
                                                 TO_TIMESTAMP('13.04.2017 00:00:00.001', 'DD.MM.YYYY HH24:MI:SS.FF3')));
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Nice formatting for application errors only
-- register in "edit application definitions" -> error handling
--------------------------------------------------------------------------------------------------------------------------------
create or replace function hriab_apex_error_handling (
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
end hriab_apex_error_handling;

--
-- end of script
--
