accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

@screen_setup
Prompt Stats in the Dictionary Cache
select :sqlid as sql_id, a.plan_hash_value as plan_hash, a.child_number, a.executions execs, a.elapsed_time/1000000 etime,
(a.elapsed_time/1000000)/decode(nvl(a.executions,0),0,1,a.executions) avg_etime,
a.disk_reads, a.disk_reads/decode(nvl(a.executions,0),0,1,a.executions) avg_disk,
a.buffer_gets, a.buffer_gets/decode(nvl(a.executions,0),0,1,a.executions) avg_buffer, decode(nvl(b.sql_handle, 'NULL'), 'NULL', '', '*') as baseline, a.optimizer_mode as optimizer
from v$sql a, dba_sql_plan_baselines b
where a.sql_id = :sqlid
and a.exact_matching_signature = b.signature (+)
and b.accepted (+) ='YES'
and b.enabled (+) ='YES'
order by a.child_number;
