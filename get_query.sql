@screen_setup
prompt  This script will attempt to regenerate a query in the library cache with binds included, into a sql file.
accept sqlid_in prompt 'Enter SQL_ID: '
accept child_number_in default '-1' prompt 'Enter Child Number [default will pick lowest child number]: '
var sqlid varchar2(30);
var child_number number;
exec :sqlid := trim('&sqlid_in');
exec :child_number := '&child_number_in';
exec dm_perf.get_query(:sqlid,'C',:child_number);
