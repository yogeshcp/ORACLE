@screen_setup
prompt Important: Queries submitted from CCL have '+0' stripped at the OCI layer.
prompt This means that the RBO plan may not be the same as in earlier versions of
prompt Oracle and may perform worse than the CBO plan.  When in doubt translate
prompt the script in CCL to look for '+0'

accept sqlid_in prompt 'Enter SQL_ID: '
accept child_number_in default '' prompt 'Enter Child Number [default will pick max child number]: '
accept execute_query_in default 'N' prompt 'Do you want to execute the query to retrieve statistics [N]: '

var sqlid varchar2(30);
var child_number number;
var execute_query varchar2(1);

exec :sqlid := trim('&sqlid_in');
exec :child_number := '&child_number_in';
exec :execute_query := '&execute_query_in';

exec dm_perf.compare_rbo(:sqlid, 'C', :child_number, :execute_query);
