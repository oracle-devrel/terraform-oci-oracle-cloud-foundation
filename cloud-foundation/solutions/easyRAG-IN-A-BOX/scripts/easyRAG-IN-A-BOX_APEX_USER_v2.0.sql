----------------------------------------------------------------
--
-- easyRAG-IN-A-BOX_APEX_USER.sql
--
-- this script will setup up a new workspace in APEX and add
-- the admin user.
--
-- Parameters:
-- 1 workspace name
-- 2 base oracle schema
-- 3 application file to load
--
-- v1.0 initial release
-- v2.0 added file to load
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
