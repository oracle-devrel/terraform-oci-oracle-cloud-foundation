-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
--------------------------------------------------------------------------------------------------------------------------------
--
-- vectorRAG-IN-A-BOX_USER.sql
--
-- this script will setup up a new user in an autonomous DB
-- and create a RAG system loading from source documents on
-- object store and the select AI framework.
--
-- v1.0 mac initial release
-- v1.1 mac implement alternative query method
-- v1.2 mac added "with target accuracy" and vriab_util_timestamp_diff
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

drop table if exists vriab_user_settings;

CREATE TABLE vriab_user_settings(
   riab_user VARCHAR2(128) NOT NULL,
   pref_type VARCHAR2(10)  NOT NULL,
   settings  JSON,
   CONSTRAINT vriab_user_settings_pk PRIMARY KEY (riab_user, pref_type)
);

-- Insert data into the settings table with sensible defaults
-- for all the three phases: chunking, index, search
--
INSERT INTO vriab_user_settings VALUES (
    'DEFAULT',
    'CHUNKING',
    json('{
          "by"          : "words",
          "max"         : 300,
          "overlap"     : 15,
          "split"       : "sentence",
          "normalize"   : "options",
          "extend"      : "true"
          }'));

--options  "norm_options" :    [ "whitespace", "punctuation" ],

INSERT INTO vriab_user_settings VALUES (
    'DEFAULT',
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
    'DEFAULT',
    'EXEC',
    json('{ "topk"     : 5,
            "distance" : "COSINE",
            "accuracy" : 95
          }'));

-- Insert credentials data into the setting table
INSERT INTO vriab_user_settings VALUES (
    'DEFAULT',
    'BUCKETCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
            "bucket_url"   :  "<<replace with your bucket url>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>"
          }'));

-- Insert credentials data into the setting table
INSERT INTO vriab_user_settings VALUES (
    'DEFAULT',
    'RAGCRED',
    json('{ "user_ocid"    :  "<<replace with your ocid>>",
            "tenancy_ocid" :  "<<replace with your tenancy ocid>>",
        "compartment_ocid" :  "<<replace with your compartment ocid>>",
            "private_key"  :  "<<replace with your private key>>",
            "fingerprint"  :  "<<replace with your fingerprint>>"
          }'));

-- exercise the setting table
select * from vriab_user_settings;

--------------------------------------------------------------------------------------------------------------------------------
-- Create the credentials for accessing the bucket with content
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure vriab_create_bucket_cred( r_user IN VARCHAR2 )
is
  uocid  varchar2(256);
  tocid  varchar2(256);
  pkey   varchar2(2000);
  fprint varchar2(256);
begin
  -- clean up
  begin
    dbms_cloud.drop_credential(credential_name => 'VRIAB_RAG_BUCKET');
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
            (select settings from vriab_user_settings
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
    credential_name => 'VRIAB_RAG_BUCKET',
    user_ocid       => SUBSTR(uocid, 2, LENGTH(uocid) - 2),
    tenancy_ocid    => SUBSTR(tocid, 2, LENGTH(tocid) - 2),
    private_key     => SUBSTR(pkey, 2, LENGTH(pkey) - 2),
    fingerprint     => SUBSTR(fprint, 2, LENGTH(fprint) - 2)
  );

end vriab_create_bucket_cred;
/

/*
-- create the bucket credential
begin
  vriab_create_bucket_cred('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Create the credentials for accessing the OCI GenAI LLM:
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure vriab_create_llm_cred( r_user in varchar2 )
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
    dbms_CLOUD.drop_credential(credential_name => 'VRIAB_LLM_CRED');
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
            (select settings from vriab_user_settings
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
      credential_name   => 'VRIAB_LLM_CRED',
      params            => json(jo.to_string));

end vriab_create_llm_cred;
/

/*
-- create the bucket credential
begin
  vriab_create_llm_cred('DEFAULT');
end;
/

-- Test that the LLM is working:
SELECT
    dbms_vector.utl_to_embedding(
        'hello',
        json('{
            "provider": "OCIGenAI",
            "credential_name": "VRIAB_LLM_CRED",
            "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
            "model": "cohere.embed-multilingual-v3.0"
        }')
    ) as TEST_EMBEDDING
FROM dual;
*/

--------------------------------------------------------------------------------------------------------------------------------
-- check status of infrastructure
--------------------------------------------------------------------------------------------------------------------------------

create or replace function vriab_check_status (
   r_user in varchar2
) return number
is
  cnt number;
begin

  -- check credentials
  select count(*) into cnt from user_credentials
   where credential_name = 'VRIAB_LLM_CRED' or
         credential_name = 'VRIAB_RAG_BUCKET';

  -- 1 = credentials not ok
  if (cnt < 2) then
    return 1;
  end if;

  -- check prefs
  select count(*) into cnt from vriab_user_settings
              where riab_user = r_user
                and pref_type = 'VECTOR' or
                    pref_type = 'EXEC'   or
                    pref_type = 'CHUNKING';

  -- 2 = prefs not ok
  if (cnt < 3) then
    return 2;
  end if;

  -- check index
  select count(*) into cnt from user_indexes
   where index_name = 'VRIAB_VECTOR_INDEX';

  -- 3 = index not present
  if (cnt = 0) then
    return 3;
  end if;

  -- all ok
  return 0;

end vriab_check_status;
/

/*
begin
 vriab_check_status('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- create the working tables for storing the chunks and the vectors
--------------------------------------------------------------------------------------------------------------------------------

-- Clean up
  drop table if exists vriab_chunks;
  drop table if exists vriab_embeddings;

  create table vriab_chunks (
            chunk_id     NUMBER,     -- The ID of the chunk
            chunk_offset NUMBER,     -- The offset of the chunk
            chunk_length NUMBER,     -- The length of the chunk
            chunk_data   CLOB        -- The actual data of the chunk
  );

  create table vriab_embeddings (
            docid    NUMBER,         -- Document ID
            body     CLOB,           -- Body text
            text_vec VECTOR,         -- Embedding vector
            url      VARCHAR2(500),  -- URL
            title    VARCHAR2(255)   -- Title
  );

--------------------------------------------------------------------------------------------------------------------------------
-- create the procedure for processing the files
-- https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/utl_to_chunks-dbms_vector_chain.html
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure vriab_process_input_files (
    r_user in varchar2
) is
    v_chunk_id     number;
    v_max_chunk_id number;
    bt             varchar2(512);
    xy             varchar2(512);
    mx             number;
    ov             number;
    sp             varchar2(512);
    xo             varchar2(512);
    ex             varchar2(512);
    nox            varchar2(512);
begin

  -- This procedure reloads all files, so clear the embeddings table and drop the index built on it
  begin
    execute immediate 'drop index VRIAB_VECTOR_INDEX';
  exception
    when others then null;
  end;
  execute immediate 'truncate table vriab_embeddings';

-- get bucket url
  select SUBSTR(xbt, 2, LENGTH(xbt) - 2) into bt
           from json_table(
            (select settings from vriab_user_settings
              where riab_user = r_user

                and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xbt varchar2(512) format json PATH '$.bucket_url'));

-- get chunking prefs
  select xxy,
         to_number(xmx),
         to_number(xov),
         xsp,
         SUBSTR(xxo, 2, LENGTH(xxo) - 2),
         xex
           into xy,mx,ov,sp,xo,ex
           from json_table(
            (select settings from vriab_user_settings
             where riab_user = r_user
               and pref_type = 'CHUNKING'
           ), '$[*]' COLUMNS (
              xxy  varchar2(256) format json PATH '$.by',
              xmx  varchar2(256) format json PATH '$.max',
              xov  varchar2(256) format json PATH '$.overlap',
              xsp  varchar2(256) format json PATH '$.split',
              xxo  varchar2(256) format json PATH '$.normalize',
              xex  varchar2(256) format json PATH '$.extend'));

   -- fix the normalization case
   if xo = 'options' then
     nox := '"normalize": "options", "norm_options" : [ "whitespace", "punctuation" ],';
   else
     nox := '"normalize": "'||xo||'",';
   end if;

   -- Loop over each file URL
   for i in ( select object_name obj_name from dbms_cloud.list_objects('VRIAB_RAG_BUCKET', ''||bt||'' )) loop

     --dbms_output.put_line(i.obj_name);

     v_chunk_id := 1;

     insert into vriab_chunks
        select
          j.chunk_id,
          j.chunk_offset,
          j.chunk_length,
          j.chunk_data
        from
          (select * from dbms_vector_chain.utl_to_chunks(
                dbms_vector_chain.utl_to_text(
                    to_blob( dbms_cloud.get_object( 'VRIAB_RAG_BUCKET', ''||bt||'/'|| i.obj_name||'' ) )
                ), 
                 json('{ "by": '||xy||', '||
                      '"max":  '||mx||', '||
                  '"overlap":  '||ov||', '||
                    '"split":  '||sp||', '||
                                  nox||
                   '"extend": '||ex||'}')
            )
          ) t,
          json_table( t.column_value, '$'
            columns (
              chunk_id     number path '$.chunk_id',
              chunk_offset number path '$.chunk_offset',
              chunk_length number path '$.chunk_length',
              chunk_data   clob   path '$.chunk_data'
            )
          ) j;


    -- Find the number of chunks for the file being processes
    select max(chunk_id) into v_max_chunk_id from vriab_chunks;

    -- Populate embeddings using chunked data
    while v_chunk_id <= v_max_chunk_id loop

      insert into vriab_embeddings ( docid, body, text_vec, url, title )
            select  chunk_id    as docid, 
            to_char(chunk_data) as body, 
                dbms_vector.utl_to_embedding(
                    chunk_data,
                    json('{
                        "provider": "OCIGenAI",
                        "credential_name": "VRIAB_LLM_CRED",
                        "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
                        "model": "cohere.embed-multilingual-v3.0",
                        "batch_size": 10
                    }') )       as text_vec,
                bt||'/'||i.obj_name  as url,
                    i.obj_name  as title
             from  vriab_chunks
            where chunk_id = v_chunk_id;

      -- Increment chunk_id for the next loop iteration
      v_chunk_id := v_chunk_id + 1;
    end loop; -- end while for embedding

    -- Clear the chunking table for next file
    execute immediate 'truncate table vriab_chunks';

    -- Sleep for a few seconds to avoid exceeding LLM calls limits
    dbms_lock.sleep(5);

  end loop; -- end file loop

  -- Commit all changes
  commit;

end vriab_process_input_files;
/


/*
begin
 vriab_process_input_files('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- create the vector index 
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure vriab_create_index (
  r_user in varchar2
) is
  id   varchar2(50);
  di   varchar2(50);
  ac   number;
  ne   number;
  ef   number;
  sa   number;
  mi   number;
  pa   number;
begin

-- Clean-up
  begin
    execute immediate 'drop index VRIAB_VECTOR_INDEX';
  exception
    when others then null;
  end;

-- get vector creation prefs
  select idx,
         dix,
         to_number(acx),
         to_number(nex),
         to_number(efx),
         to_number(sax),
         to_number(mix),
         to_number(pax)
           into id,di,ac,ne,ef,sa,mi,pa
           from json_table(
            (select settings from vriab_user_settings
             where riab_user = r_user
               and pref_type = 'VECTOR'
           ), '$[*]' COLUMNS (
              idx  varchar2(256) format json PATH '$.idxtype',
              dix  varchar2(256) format json PATH '$.distance',
              acx  varchar2(256) format json PATH '$.accuracy',
              nex  varchar2(256) format json PATH '$.neighbors',
              efx  varchar2(256) format json PATH '$.efconstr',
              sax  varchar2(256) format json PATH '$.samples',
              mix  varchar2(256) format json PATH '$.minvect',
              pax  varchar2(256) format json PATH '$.parallel'));

  id := SUBSTR(id, 2, LENGTH(id) - 2);
  di := SUBSTR(di, 2, LENGTH(di) - 2);

  if (id = 'HNSW') then
    -- HNSW index
    execute immediate 'CREATE VECTOR INDEX VRIAB_VECTOR_INDEX ON vriab_embeddings(text_vec) '||
             'ORGANIZATION INMEMORY NEIGHBOR GRAPH '||
             'DISTANCE '||di||
             ' WITH TARGET ACCURACY '||ac||
             ' PARAMETERS (type HNSW, '||
                          'neighbors '||ne||', '||
                          'efconstruction '||ef||') '||
                          'parallel '||pa;
  else
    -- IVF index
    execute immediate 'CREATE VECTOR INDEX VRIAB_VECTOR_INDEX ON vriab_embeddings(text_vec) '||
             'ORGANIZATION NEIGHBOR PARTITIONS '||
             'DISTANCE '||di||
             ' WITH TARGET ACCURACY '||ac||
             ' PARAMETERS (type IVF, '||
                          'samples_per_partition '||sa||', '||
                          'min_vectors_per_partition '||mi||') '||
                          'parallel '||pa;
  end if; -- index type
end vriab_create_index; 
/

/*
-- create the index and the profile
begin
  vriab_create_index('DEFAULT');
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- deliver the chunking and the create
-- vector syntax from the prefs. It duplicates some code (bad) but it
-- formats the output nicely, so worth duplicating.
--------------------------------------------------------------------------------------------------------------------------------

create or replace function vriab_create_index_code (
  r_user in varchar2
) return clob is
  id   varchar2(50);
  di   varchar2(50);
  ac   number;
  ne   number;
  ef   number;
  sa   number;
  mi   number;
  pa   number;
  xy   varchar2(512);
  mx   number;
  ov   number;
  sp   varchar2(512);
  xo   varchar2(512);
  ex   varchar2(512);
  nox  varchar2(512);
  cc   clob;
  ch   clob;
begin

-- get chunking prefs
  select xxy,
         to_number(xmx),
         to_number(xov),
         xsp,
         SUBSTR(xxo, 2, LENGTH(xxo) - 2),
         xex
           into xy,mx,ov,sp,xo,ex
           from json_table(
            (select settings from vriab_user_settings
             where riab_user = r_user
               and pref_type = 'CHUNKING'
           ), '$[*]' COLUMNS (
              xxy  varchar2(256) format json PATH '$.by',
              xmx  varchar2(256) format json PATH '$.max',
              xov  varchar2(256) format json PATH '$.overlap',
              xsp  varchar2(256) format json PATH '$.split',
              xxo  varchar2(256) format json PATH '$.normalize',
              xex  varchar2(256) format json PATH '$.extend'));

   -- fix the normalization case
   if xo = 'options' then
     nox := '"normalize": "options", "norm_options" : [ "whitespace", "punctuation" ],';
   else
     nox := '"normalize": "'||xo||'",';
   end if;

   ch := 'insert into vriab_chunks
    select
      j.chunk_id,
      j.chunk_offset,
      j.chunk_length,
      j.chunk_data
    from
      (select * from
         dbms_vector_chain.utl_to_chunks(
           dbms_vector_chain.utl_to_text(
             to_blob( dbms_cloud.get_object( <BUCKET CREDS>, <FULL PATH TO FILE> ) )
           ), 
           json(''{ "by": '||xy||', '|| 
                   '"max":  '||mx||', '|| 
                   '"overlap":  '||ov||', '||
                    '"split":  '||sp||', '|| chr(10)||
'                  '|| nox||
                   '"extend": '||ex||'}'')
         )
       ) t,
         json_table( t.column_value, ''$''
           columns (
             chunk_id     number path ''$.chunk_id'',
             chunk_offset number path ''$.chunk_offset'',
             chunk_length number path ''$.chunk_length'',
             chunk_data   clob   path ''$.chunk_data''
           )
        ) j;';

-- get vector creation prefs
  select idx,
         dix,
         to_number(acx),
         to_number(nex),
         to_number(efx),
         to_number(sax),
         to_number(mix),
         to_number(pax)
           into id,di,ac,ne,ef,sa,mi,pa
           from json_table(
            (select settings from vriab_user_settings
             where riab_user = r_user
               and pref_type = 'VECTOR'
           ), '$[*]' COLUMNS (
              idx  varchar2(256) format json PATH '$.idxtype',
              dix  varchar2(256) format json PATH '$.distance',
              acx  varchar2(256) format json PATH '$.accuracy',
              nex  varchar2(256) format json PATH '$.neighbors',
              efx  varchar2(256) format json PATH '$.efconstr',
              sax  varchar2(256) format json PATH '$.samples',
              mix  varchar2(256) format json PATH '$.minvect',
              pax  varchar2(256) format json PATH '$.parallel'));

  id := SUBSTR(id, 2, LENGTH(id) - 2);
  di := SUBSTR(di, 2, LENGTH(di) - 2);

  if (id = 'HNSW') then
    -- HNSW index
    cc := 'CREATE VECTOR INDEX VRIAB_VECTOR_INDEX ON vriab_embeddings(text_vec) '|| chr(10) ||
          '  ORGANIZATION INMEMORY NEIGHBOR GRAPH '|| chr(10) ||
          '    DISTANCE '||di|| chr(10) ||
          '    WITH TARGET ACCURACY '||ac|| chr(10) ||
          '    PARAMETERS (type HNSW, '|| chr(10) ||
          '                neighbors '||ne||', '|| chr(10) ||
          '                efconstruction '||ef||') '|| chr(10) ||
          '    PARALLEL '||pa || ';';
  else
    -- IVF index
    cc := 'CREATE VECTOR INDEX VRIAB_VECTOR_INDEX ON vriab_embeddings(text_vec) '|| chr(10) ||
          '  ORGANIZATION NEIGHBOR PARTITIONS '|| chr(10) ||
          '    DISTANCE '||di|| chr(10) ||
          '    WITH TARGET ACCURACY '||ac|| chr(10) ||
          '    PARAMETERS (type IVF, '|| chr(10) ||
          '                samples_per_partition '||sa||', '|| chr(10) ||
          '                min_vectors_per_partition '||mi||') '|| chr(10) ||
          '    PARALLEL '||pa || ';';
  end if; -- index type

  cc := 'Chunking Code' || chr(10) || '---------------------------------------------' || chr(10) ||
          ch || chr(10) || chr(10) || '---------------------------------------------' || chr(10) ||
    'Create Index Code' || chr(10) || '---------------------------------------------' || chr(10) ||
          cc || chr(10)            || '---------------------------------------------' ;

  return cc;
end vriab_create_index_code; 
/


/*
-- test
declare
  cc clob;
begin
  cc := vriab_create_index_code('DEFAULT');
  dbms_output.put_line(cc);
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
-- use the scheduler to call the chunking/vectorizing procedure
-- that will timeout in APEX anyway (ws = with scheduler) 
--------------------------------------------------------------------------------------------------------------------------------

create or replace procedure vriab_process_input_files_ws  (
  r_user in varchar2
) is
begin

  -- clean up
  begin
    DBMS_SCHEDULER.DROP_JOB (
        job_name => 'VRIAB_PROC_FILES_JOB',
        force    => true);
    EXCEPTION when others then null;
  end;

  begin
    DBMS_SCHEDULER.DROP_PROGRAM (
      program_name  => 'VRIAB_PROC_FILES_PROG',
             force  => true);
    EXCEPTION when others then null;
  end;

  DBMS_SCHEDULER.CREATE_PROGRAM (
    program_name      => 'VRIAB_PROC_FILES_PROG',
    program_action    => 'vriab_process_input_files',
    program_type      => 'STORED_PROCEDURE',
    number_of_arguments => 1,
    enabled => false);

  DBMS_SCHEDULER.define_program_argument(
   program_name      => 'VRIAB_PROC_FILES_PROG',
   argument_position => 1,
   argument_name     => 'R_USER',
   argument_type     => 'VARCHAR2');

  DBMS_SCHEDULER.enable(name => 'VRIAB_PROC_FILES_PROG');

  -- run immediately
  DBMS_SCHEDULER.CREATE_JOB (
    job_name => 'VRIAB_PROC_FILES_JOB',
    program_name => 'VRIAB_PROC_FILES_PROG',
    enabled => false);

  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE (
   job_name => 'VRIAB_PROC_FILES_JOB',
   argument_position  => 1,
   argument_value => r_user);

  DBMS_SCHEDULER.enable(name => 'VRIAB_PROC_FILES_JOB');


end vriab_process_input_files_ws;
/

--------------------------------------------------------------------------------------------------------------------------------
-- check the status of the sources
--------------------------------------------------------------------------------------------------------------------------------
-- clean up
drop table if exists vriab_doc_sources;

create table vriab_doc_sources(
    id        number generated by default as identity (increment by 1),
    fname     varchar(500),
    vstatus   varchar(50),
    chunks    number,
    fstatus   varchar2(50));

create or replace procedure vriab_check_sources (
  r_user in varchar2
) is
  cnt number;
  bt  varchar2(512);
begin

  -- clean up
  execute immediate 'truncate table vriab_doc_sources';

  -- get bucket url (clean of quote chars)
  select SUBSTR(xbt, 2, LENGTH(xbt) - 2) into bt
           from json_table(
            (select settings from vriab_user_settings
              where riab_user = r_user
                and pref_type = 'BUCKETCRED'
           ), '$[*]' COLUMNS (
              xbt varchar2(512) format json PATH '$.bucket_url'));

  -- insert the current index status
  insert into vriab_doc_sources ( fname, vstatus, chunks, fstatus )
     select SUBSTR(v.url,(INSTR(v.url,'/',-1,1)+1),length(v.url)), 'VECTORIZED', count(v.docid), 'OBSOLETE' from vriab_embeddings v group by v.url;

  -- check if the files on object store changed...
  for i in ( select object_name obj_name from dbms_cloud.list_objects('VRIAB_RAG_BUCKET',bt) ) loop

    select count(fname) into cnt from vriab_doc_sources
     where fname = i.obj_name;
    if (cnt = 0) then
      -- new file found
      insert into vriab_doc_sources values (DEFAULT, i.obj_name, 'UNPROCESSED', 0, 'CURRENT');
    else
      -- existing file already processed
      update vriab_doc_sources
         set fstatus = 'CURRENT'
       where fname = i.obj_name;
    end if;
  end loop;

  commit;
end vriab_check_sources;
/

/*
-- update the table
begin
  vriab_check_sources('DEFAULT');
end;
/

-- verify URLs
select * from riab_doc_sources;

*/

--------------------------------------------------------------------------------------------------------------------------------
-- You can find information about your vector indexes by looking at ALL_INDEXES, DBA_INDEXES, and USER_INDEXES family of views.
-- The columns of interest are INDEX_TYPE (VECTOR) and INDEX_SUBTYPE (INMEMORY_NEIGHBOR_GRAPH_HNSW or NEIGHBOR_PARTITIONS_IVF). 
-- https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/index-accuracy-report.html
-- https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/vector-index-status-checkpoint-and-advisor-procedures.html
--

--------------------------------------------------------------------------------------------------------------------------------
-- Get the answer!
--------------------------------------------------------------------------------------------------------------------------------
create or replace procedure vriab_get_answer (
   user_question IN  CLOB,
   rag_user      IN  VARCHAR2,
   llm_answer    OUT CLOB,    -- new answer
   rag_context   IN  OUT CLOB, -- in input brings in the cumulated previous answers to augment the context
                              -- in output shows the inner workings
   use_index     IN  bool default TRUE,
   use_plsql     IN  bool default FALSE
) is
  prompt  CLOB;
  context CLOB;
  sources CLOB;

  tk      NUMBER;
  dm      VARCHAR2(50);
  ac      NUMBER;

  l_cols json_array_t := json_array_t();
  t_json json_array_t := json_array_t();

  query_vec VECTOR;

  rid   number;
  mid   number;
  mtext clob;
  murl  varchar2(512);

  a_json clob;

begin

 -- Generate embedding for the query
 query_vec := dbms_vector.utl_to_embedding(
        user_question,
        json('{ "provider": "OCIGenAI",
                "credential_name": "VRIAB_LLM_CRED",
                "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
                "model": "cohere.embed-multilingual-v3.0"
          }')
        );

  -- initialize the context
  context     := rag_context;
  prompt      := '';

  -- get query prefs
  select to_number(tkx),
            SUBSTR(dmx, 2, LENGTH(dmx) - 2),
         to_number(acx)
           into tk,dm,ac
           from json_table(
            (select settings from vriab_user_settings
             where riab_user = rag_user
               and pref_type = 'EXEC'
           ), '$[*]' COLUMNS (
              tkx  varchar2(256) format json PATH '$.topk',
              dmx  varchar2(256) format json PATH '$.distance',
              acx  varchar2(256) format json PATH '$.accuracy'));

  sources := 'Sources: ';

  -- select your death
  if (use_plsql) then
    -- select columns to be returned, we don't need the vectors
    l_cols.append('DBMSVECTOR_ROWNUM');
    l_cols.append('DOCID');
    l_cols.append('BODY');
    l_cols.append('URL');

    t_json := DBMS_VECTOR.query(
      TAB_NAME        => 'VRIAB_EMBEDDINGS',
      VEC_COL_NAME    => 'TEXT_VEC',
      QUERY_VECTOR    => query_vec,
      TOP_K           => tk,
      VEC_PROJ_COLS   => l_cols, 
      IDX_NAME        =>  'VRIAB_VECTOR_INDEX',
      DISTANCE_METRIC => dm,
      USE_INDEX       => use_index,
      ACCURACY        => ac,
      IDX_PARAMETERS  => null );

    for i in 1..t_json.get_size() loop
      rid :=   TREAT (t_json.get (i - 1) AS json_object_t).get_number ('DBMSVECTOR_ROWNUM');
      mid :=   TREAT (t_json.get (i - 1) AS json_object_t).get_number ('DOCID');
      mtext := TREAT (t_json.get (i - 1) AS json_object_t).get_clob   ('BODY');
      murl :=  TREAT (t_json.get (i - 1) AS json_object_t).get_string ('URL');

      -- concatenate each value to the string
      context := context || ' ' || mtext;
      sources := sources || ' ' || 'URL: ' || murl;
    end loop;

  else -- use plsql

    for i in (select docid, body, VECTOR_DISTANCE(text_vec, query_vec) as score, url
                from  vriab_embeddings
               order by score asc
               fetch first tk rows only with target accuracy ac) loop

      -- concatenate each value to the string
      context := context || ' ' || i.body;
      sources := sources || ' ' || 'URL: ' || i.url;


      t_json.append( json_object( 'DOCID' value i.docid, 'SCORE' value i.score, 'BODY' value i.body, 'URL' value i.url format json) );
    end loop;

  end if; -- use plsql

  -- make it pretty for visualization. NB if returning the vectors it will break the json_serialize
  a_json := t_json.to_clob;
  select JSON_SERIALIZE(a_json returning clob PRETTY) into a_json from dual;


  -- strip some of the annoying html tags
  -- select REGEXP_REPLACE(context, '<.+?>') as t into context from dual;  
  -- DBMS_OUTPUT.PUT_LINE('Generated context: ' || context);

  -- concatenate strings and format it as an enhanced prompt to the LLM
  prompt := 'Answer the following question using the supplied context assuming you are a subject matter expert; include found URLs in a separated category labeled Sources. Question: '
             || user_question || ' Context: ' || context ||' '|| sources || ' ' || rag_context;

  --DBMS_OUTPUT.PUT_LINE('Postprocessed prompt: ' || prompt);

  -- overwrite the passed in context with the locally generated one
  rag_context := '++++Chunks++++' || chr(10) || a_json || chr(10) || '****Context**** '|| chr(10) || context || chr(10) || '----Sources---- '|| chr(10) || sources;

  select dbms_vector_chain.utl_to_generate_text(
            prompt, json('{
     "provider"       : "ocigenai",
     "credential_name": "VRIAB_LLM_CRED",
     "url"            : "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/chat",
     "model"          : "cohere.command-r-plus-08-2024",
     "chatRequest"    : {
                      "maxTokens": 2048
                        }
   }')) into llm_answer
   from dual;

end vriab_get_answer;
/

/*
-- exercise the routine
VAR aa CLOB;
VAR bb CLOB;
begin
  -- read this question from the user
  vriab_get_answer( to_clob('who is part of the data in industry team?'), 'DEFAULT', :aa, :bb, true, false);
  DBMS_OUTPUT.PUT_LINE('Answer: ' || :aa);
  DBMS_OUTPUT.PUT_LINE('Context: ' || :bb);
end;
/
*/

--------------------------------------------------------------------------------------------------------------------------------
/* *********************************************************************************
-- alternative way to query
CREATE OR REPLACE FUNCTION vriab_return_results (
    p_query IN VARCHAR2,
    top_k IN NUMBER
) RETURN SYS_REFCURSOR IS
    v_results SYS_REFCURSOR;
    query_vec VECTOR;
BEGIN
    -- Generate embedding for the query
    query_vec := dbms_vector.utl_to_embedding(
        p_query,
        json('{
            "provider": "OCIGenAI",
            "credential_name": "VRIAB_LLM_CRED",
            "url": "https://inference.generativeai.us-chicago-1.oci.oraclecloud.com/20231130/actions/embedText",
            "model": "cohere.embed-multilingual-v3.0"
        }')
    );

    -- Open a cursor to return results ordered by the vector distance (most similar first)
    OPEN v_results FOR
        SELECT DOCID, BODY, VECTOR_DISTANCE(text_vec, query_vec) AS SCORE, URL, TITLE
        FROM  vriab_embeddings
        ORDER BY SCORE ASC
        FETCH FIRST top_k ROWS ONLY;

    -- Return the cursor
    RETURN v_results;
END;
/

select VRIAB_RETURN_RESULTS('what is massimo?',5) from dual;

********************************************************************************* */
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Calculates msecs between timestamps
--------------------------------------------------------------------------------------------------------------------------------
create or replace function vriab_util_timestamp_diff (
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

--------------------------------------------------------------------------------------------------------------------------------
-- Nice formatting for application errors only
-- register in "edit application definitions" -> error handling
--------------------------------------------------------------------------------------------------------------------------------
create or replace function vriab_apex_error_handling (
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
end vriab_apex_error_handling;

--
-- end of script
--
