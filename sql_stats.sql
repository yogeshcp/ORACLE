@screen_setup
accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid VARCHAR2(30);
exec :sqlid := trim('&sqlid_in');

@sql_stats_query