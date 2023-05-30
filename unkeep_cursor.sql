accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

@screen_setup
prompt This procedure will "unPin" a  given sql_id in the Library Cache
prompt Discovering pinned cursors... This may take a moment.
select sql_id, child_number, plan_hash_value from v$sql where KEPT_VERSIONS > 0;
exec dm_perf.unkeep_cursor(:sqlid);
