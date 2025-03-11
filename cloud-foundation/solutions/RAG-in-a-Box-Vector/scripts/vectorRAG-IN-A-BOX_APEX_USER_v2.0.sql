-- Copyright © 2025, Oracle and/or its affiliates.
-- All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl
--------------------------------------------------------------------------------------------------------------------------------
--
-- vectorRAG-IN-A-BOX_APEX_USER.sql
--
-- this script will load the application code
--
-- v1.0 mac initial release
-- v2.0 mac added file to load
--
-- Parameters:
--
-- 1 workspace name as entered in the APEX ADMIN script
-- 2 base oracle schema as entered in the ADMIN
-- 3 application file to load, including path if needed
--
----------------------------------------------------------------

----------------------------------------------------------------
--
-- ************ AS APEX ADMIN user (using the DB password!)
--
----------------------------------------------------------------

declare
    l_workspace_id number;
begin
    select workspace_id into l_workspace_id
      from apex_workspaces
     where workspace = '&1';
    --
    apex_application_install.set_workspace_id( l_workspace_id );
    apex_application_install.generate_offset;
    apex_application_install.set_schema( '&2' );
end;
/
 
@&3

--
-- end of script
--
