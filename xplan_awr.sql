accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid VARCHAR2(30);
exec :sqlid := trim('&sqlid_in');

accept plan_hash_value_in prompt 'Enter Plan Hash Value: '
var plan_hash_value NUMBER;
exec :plan_hash_value := '&plan_hash_value_in';

@screen_setup
select * from table(dbms_xplan.display_awr(:sqlid,:plan_hash_value,'','ADVANCED +PEEKED_BINDS -PROJECTION -ALIAS'))
/
