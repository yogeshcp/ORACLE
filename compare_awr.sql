@screen_setup
prompt Important: Queries submitted from CCL have '+0' stripped at the OCI layer.
prompt This means that the RBO plan may not be the same as in earlier versions of
prompt Oracle and may perform worse than the CBO plan.  When in doubt translate
prompt the script in CCL to look for '+0'

accept sqlid_in prompt 'Enter SQL_ID: '
accept snap_id_in default '' prompt 'Enter Snap ID [default will pick max snap_id]: '
accept execute_query_in default 'N' prompt 'Do you want to execute the query to retrieve statistics [N]: '

var sqlid varchar2(30);
var snap_id number;
var execute_query varchar2(1);

exec :sqlid := trim('&sqlid_in');
exec :snap_id := '&snap_id_in';
exec :execute_query := '&execute_query_in';

exec dm_perf.compare_rbo(:sqlid, 'A', :snap_id, :execute_query);
