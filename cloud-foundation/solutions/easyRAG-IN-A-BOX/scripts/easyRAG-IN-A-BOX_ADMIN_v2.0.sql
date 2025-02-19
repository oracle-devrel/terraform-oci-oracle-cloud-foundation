----------------------------------------------------------------
--
-- easyRAG-IN-A-BOX ADMIN.txt
--
-- this script will setup up a new user in an autonomous DB
-- and create a RAG system loading from source documents on
-- object store and the select AI framework.
--
--
-- v1.0 initial release
-- v1.1 add credentials management
-- v1.2 add username parametrization
-- v1.3 fix grant on pipeline to avoid silent error
-- v1.4 added user creation
-- v1.5 refactored user creation and added exit for terraform
--
----------------------------------------------------------------

----------------------------------------------------------------
--
-- ************ IN SHELL
--
----------------------------------------------------------------
-- 
-- If never done before, create API Key, download both PRIVATE and PUBLIC key files
-- Convert PRIVATE KEY into the needed format for the credentials
-- DO NOT USE rtf, just plain text files
--
-- awk -v ORS='\\n' '1' /Users/massimo/Downloads/MASSIMO.CASTELLI@ORACLE.COM_2024-11-14T14_26_42.293Z.pem | pbcopy
--
--
----------------------------------------------------------------
--
-- ************ AS ADMIN
--
-- Run this script in ADMIN like this
--
-- @easyRAG-IN-A-BOX_ADMIN_v1.2 <user> <password>
--
----------------------------------------------------------------

-- make sure to be ADMIN
begin
  if upper(user) != 'ADMIN' then
    raise_application_error(-20000, 'this script must be run as the admin user');
  end if;
end;
/

create user &1 identified by "&2";
alter profile default limit password_reuse_time unlimited;
alter profile default limit password_life_time  unlimited;

GRANT dwrole            to &1;
grant DB_DEVELOPER_ROLE to &1;

--grant CONSOLE_DEVELOPER to &1;
--grant GRAPH_DEVELOPER   to &1;
--grant OML_DEVELOPER     to &1;
--ALTER USER &1 DEFAULT ROLE CONNECT,DB_DEVELOPER_ROLE,RESOURCE,CONSOLE_DEVELOPER,DWROLE,GRAPH_DEVELOPER,OML_DEVELOPER;

-- Grants to allow creation and manipulation of vector tables
GRANT CREATE TABLE TO &1;

ALTER USER &1 DEFAULT TABLESPACE DATA TEMPORARY TABLESPACE TEMP;
ALTER USER &1 QUOTA UNLIMITED ON DATA;

-- PRIVILEGES
-- needed to use the SLEEP function in ingestion routine
GRANT EXECUTE ON DBMS_LOCK TO &1;

-- needed if you use select AI
GRANT EXECUTE ON DBMS_CLOUD_AI TO &1;

-- DBMS_VECTOR for vector search operations
GRANT EXECUTE ON DBMS_VECTOR TO &1;

-- DBMS_CLOUD for accessing Object Storage (if used in your setup)
GRANT EXECUTE ON DBMS_CLOUD TO &1;

-- DBMS_CREDENTIAL for managing and using stored OCI credentials
GRANT EXECUTE ON DBMS_CREDENTIAL TO &1;

-- JSON functions, if JSON is used in vector search
GRANT EXECUTE ON DBMS_JSON TO &1;

-- without these roles the user will not be able to fully create a vector index using the select AI packages.
GRANT EXECUTE ON DBMS_CLOUD_PIPELINE to &1;

--
-- set ACLs to allow reaching genai services etc etc
--
-- substitute "append" with "remove" to reverse the command
--
begin
-- Allow all hosts for HTTP/HTTP_PROXY
    dbms_network_acl_admin.append_host_ace(
        host =>'*',
        lower_port => 443,
        upper_port => 443,
        ace => xs$ace_type(
            privilege_list => xs$name_list('http', 'http_proxy'),
            principal_name => upper('&1'),
            principal_type => xs_acl.ptype_db)
    );
end;
/

begin
-- Allow all hosts for HTTP/HTTP_PROXY
    dbms_network_acl_admin.append_host_ace(
        host =>'*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('connect', 'resolve'),
            principal_name => upper('&1'),
            principal_type => xs_acl.ptype_db)
    );
end;
/

-- verify the acls
select * from DBA_HOST_ACES where principal = '&1';


-- REST enable the account
begin
    ORDS_ADMIN.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => '&1',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => upper('&1'),
        p_auto_rest_auth=> TRUE
    );

/*
-- enable DATA SHARING
    C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
            SCHEMA_NAME => upper('&1'),
            ENABLED => TRUE
    );
*/

end;
/

--
-- end of script
--
