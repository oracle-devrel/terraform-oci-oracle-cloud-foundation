-- as moviestream
-- Chat ADB app
BEGIN    
    admin.workshop.write('setup for app install as moviestream', 2);
    
    -- Set the name of the workspace in which the app needs to be installed
    apex_application_install.set_workspace('MOVIESTREAM');

    -- Setting the application id to 101
    apex_application_install.set_application_id(101);
    apex_application_install.generate_offset();

    -- Setting the Schema
    apex_application_install.set_schema('MOVIESTREAM');

    -- Setting application alias
    apex_application_install.set_application_alias('CHATDB');

    -- Set Auto Install Supporting Objects
    apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );

END;
/
@./scripts/f101.sql

-- GenAI Projects App 
BEGIN
    -- Setting the application id to 100
    apex_application_install.set_application_id(100);
    apex_application_install.generate_offset();

   -- Setting application alias
    apex_application_install.set_application_alias('GENAI-PROJECTS');

    -- Set Auto Install Supporting Objects
    apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );
END;
/
@./scripts/f100-genai-project.sql

-- Setup Select AI. Create 2 profiles. One for chat and the other for GenAI projects
begin
    admin.workshop.write('Setup ai profile for chat', 2);
    
    -- Chat
    dbms_cloud_ai.drop_profile(
        profile_name => 'genai',
        force => true
        );

    dbms_cloud_ai.create_profile(
        profile_name => 'genai',
        attributes =>       
            '{"provider": "oci",
            "credential_name": "OCI$RESOURCE_PRINCIPAL",
            "comments":"true",            
            "object_list": [
                {"owner": "MOVIESTREAM", "name": "GENRE"},
                {"owner": "MOVIESTREAM", "name": "CUSTOMER"},
                {"owner": "MOVIESTREAM", "name": "PIZZA_SHOP"},
                {"owner": "MOVIESTREAM", "name": "STREAMS"},            
                {"owner": "MOVIESTREAM", "name": "MOVIES"},
                {"owner": "MOVIESTREAM", "name": "ACTORS"}
            ]
            }'
        );
        
end;
/