@screen_setup
SELECT owner, name FROM dba_sqlset;

ACCEPT sqlset_in PROMPT 'Enter SQLSET Name: '
var sqlset VARCHAR2(30);
exec :sqlset := trim(upper('&sqlset_in'));

ACCEPT sqlset_owner_in PROMPT 'Enter SQLSET Owner: '
var sqlset_owner VARCHAR2(30);
exec :sqlset_owner := trim(upper('&sqlset_owner_in'));

ACCEPT sqlid_in PROMPT 'Enter SQL_ID: '
var sqlid VARCHAR2(30);
exec :sqlid := trim('&sqlid_in');

ACCEPT plan_hash_in PROMPT 'Enter Plan Hash Value: '
var plan_hash NUMBER;
exec :plan_hash := '&plan_hash_in';

@screen_setup
SELECT substr(PLAN_TABLE_OUTPUT, 1, 155) as plan_data
FROM table(dbms_xplan.display_sqlset(:sqlset, :sqlid, :plan_hash, 'IOSTATS ADVANCED +PEEKED_BINDS -PROJECTION -ALIAS', :sqlset_owner));
