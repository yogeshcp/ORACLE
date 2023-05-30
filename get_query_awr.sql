@screen_setup
Prompt get_query.sql
prompt   Attempt to regenerate query from AWR with binds included.
accept sqlid_in  prompt 'Enter SQL_ID: '
accept snap_id_in default '-1' prompt 'Enter Snap ID [default will the most recent AWR snapshot with sql_id present]: '
var sqlid varchar2(30);
var snap_id_in number;
exec :sqlid := trim('&sqlid_in');
exec :snap_id_in := '&snap_id_in';
exec dm_perf.get_query(:sqlid,'A',:snap_id_in);
