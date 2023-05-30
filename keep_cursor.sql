accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

@screen_setup
prompt This procedure will "Pin" a  given sql_id in the Library Cache
prompt the cursor will remain in cache until @unkeep_cursor is run
prompt or the instance is restarted.
exec dm_perf.keep_cursor(:sqlid);
