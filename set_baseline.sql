@screen_setup
prompt This procedure will create a baseline from a cursor
prompt and plan_hash_value that already exists in the cache
prompt Tip: @sql_stats displays this info for a given sql_id
prompt
accept sqlid_in  prompt 'Enter sql_id: '
accept phv_in    prompt 'Enter plan_hash_value: '
accept msg_in    prompt 'Enter your name and why this baseline is needed?: '
var sqlid varchar2(30);
var msg varchar2(255);
var phv number;
exec :sqlid := trim('&sqlid_in');
exec :phv := '&phv_in';
exec :msg := trim('&msg_in');

exec dm_perf.set_baseline(sqlid => :sqlid, phv => :phv,msg=>'dm_perf.set_baseline, Created by:'||:msg);

