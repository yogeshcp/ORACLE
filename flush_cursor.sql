accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

@screen_setup

prompt This procedure will flush all children from a given sql_id from the Library Cache
exec dm_perf.flush_cursor(:sqlid);
