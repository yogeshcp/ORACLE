@screen_setup
COLUMN child_cnt FORMAT 99999 HEADING "CHILD|COUNT"
COLUMN last_child FORMAT 99999 HEADING "LAST|CHILD"
COLUMN script FORMAT a43

select /* <dm_perf.find_sql> */
       vsph.sql_id,
       vsph.plan_hash_value as plan_hash,
       vsph.first_load_time,
       vsph.executions execs,
       vsph.elapsed_time/1000000 as etime,
       (vsph.elapsed_time/1000000)/decode(nvl(vsph.executions,0),0,1,vsph.executions) avg_etime,
       vsph.disk_reads,
       vsph.buffer_gets,
       nvl(to_char(substr(vsph.sql_text, regexp_instr(vsph.sql_text,'<',1)+1, (regexp_instr(vsph.sql_text,'>',1)-regexp_instr(vsph.sql_text,'<',1)-1))), substr(vsph.sql_text, 1, 43)) script
from v$sqlarea_plan_hash vsph, dba_sql_plan_baselines b
where lower(vsph.sql_text) like lower('%&search_string%') and vsph.sql_text not like '%dm_perf.find_sql%'
and vsph.exact_matching_signature = b.signature (+)
and b.accepted (+) = 'YES'
and b.enabled (+) = 'YES'
order by nvl(to_char(substr(vsph.sql_text, regexp_instr(vsph.sql_text,'<',1)+1, (regexp_instr(vsph.sql_text,'>',1)-regexp_instr(vsph.sql_text,'<',1)-1))), substr(vsph.sql_text, 1, 43)), vsph.first_load_time;
set verify on