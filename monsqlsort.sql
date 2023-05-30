@screen_setup
accept lookback_hours_in default 1 prompt 'Hours to look back, supplying -1 for all SQL Monitoring data [1]: '
set feedback off
var lookback_hours number;
exec :lookback_hours := &lookback_hours_in;

var search_string VARCHAR2(50);
exec :search_string := 'DM_PERF_NOFILTER';

var sorter VARCHAR2(13);
exec :sorter := 'MONSQLSORT';

@monsql_query