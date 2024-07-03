SELECT 'CREATE SYNONYM "' || a.table_name || '" FOR "' || a.owner || '"."' || a.table_name || '";'
FROM   all_tables a
WHERE  a.owner = 'COMMS_LAKEHOUSE_TELECOM_TOWER';

exit;
/