@screen_setup

ACCEPT sqlid_in prompt 'Enter SQL_ID: '
var sqlid VARCHAR2(30);
exec :sqlid := trim('&sqlid_in');

ACCEPT sid_in prompt 'Enter SID: '
var sid NUMBER;
exec :sid := '&sid_in';

col report format a160
select DBMS_SQLTUNE.REPORT_SQL_MONITOR(sql_id=>:sqlid,session_id=> :sid) as report from dual;
