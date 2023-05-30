@screen_setup
prompt This procedure will create a baseline for a query from a hinted sql_id
prompt and plan_hash_value that already exists in the cache
prompt
accept sqlid_in    prompt 'Enter sql_id (to be baselined): '
accept sqlid_hint  prompt 'Enter hinted sql_id: '
accept phv_hint    prompt 'Enter hinted_plan_hash_value: '
accept msg_in      prompt 'Enter your name and why this baseline is needed?: '
var sqlid_b varchar2(30);
var sqlid_h varchar2(30);
var phv number;
var msg varchar2(255);
exec :sqlid_b := trim('&sqlid_in');
exec :sqlid_h := trim('&sqlid_hint');
exec :phv := '&phv_hint';
exec :msg := trim('&msg_in');

exec dm_perf.set_hint (:sqlid_b, :sqlid_h, :phv, msg=>'dm_perf.set_hint, Created by:'||:msg);
