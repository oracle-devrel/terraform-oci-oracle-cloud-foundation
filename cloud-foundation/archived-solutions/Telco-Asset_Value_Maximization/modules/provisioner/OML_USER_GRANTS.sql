
-- BEGIN
--     FOR obj_name IN (SELECT object_name FROM dba_objects WHERE owner = 'COMMS_LAKEHOUSE_TELECOM_TOWER') 
--     LOOP
--         EXECUTE IMMEDIATE 'GRANT SELECT ON COMMS_LAKEHOUSE_TELECOM_TOWER.' || obj_name.object_name || ' TO DMISHRA';
--     END LOOP;
-- END;
-- /

-- exit;
-- /