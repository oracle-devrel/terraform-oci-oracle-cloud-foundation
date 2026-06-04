set define off;
set serveroutput on;

prompt === customer_profile_oracle count ===
select count(*) as profile_count
from customer_profile_oracle;

prompt === sample rows ===
select customer_id, full_name, email
from customer_profile_oracle
fetch first 5 rows only;

prompt === function test ===
select get_customer_profile_json('Tammy Bryant') as profile_json
from dual;


exit;
/