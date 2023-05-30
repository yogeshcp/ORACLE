@screen_setup

set feedback off
var lookback_hours number;
exec :lookback_hours := 0;

var search_string VARCHAR2(50);
exec :search_string := 'DM_PERF_NOFILTER';

var sorter VARCHAR2(13);
exec :sorter := 'MONSQL';

@monsql_query