@screen_setup
accept lookback_hours_in default 1 prompt 'Hours to look back, supplying -1 for all SQL Monitoring data [1]: '
set feedback off
var lookback_hours number;
exec :lookback_hours := &lookback_hours_in;

col script format a50
col start_time format a10
col Sid_Serial format a16
col elapsed format 999999
set feedback off
SELECT /* <dm_perf.monsql_query> */
       vsm.sql_id,
       min(decode(vs.sql_plan_baseline, null, null,'*')) as b,
       min(decode(instr(vs.sql_text, ':O1:'), 0, ' ', '*')) as g,
       vsm.sql_plan_hash_value as plan_hash,
       count(*) as occurences,
       sum(vsm.elapsed_time/1000000)/count(*) as avg_seconds,
       sum(vsm.buffer_gets)/count(*) as avg_buffer,
       sum(vsm.disk_reads)/count(*) as avg_disk,
       max(nvl(to_char(substr(vs.sql_text, regexp_instr(vs.sql_text,'<',1)+1, (regexp_instr(vs.sql_text,'>',1)-regexp_instr(vs.sql_text,'<',1)-1))), substr(vs.sql_text, 1, 50))) as script
FROM v$sql_monitor vsm, v$sqlarea vs
WHERE vsm.sql_id = vs.sql_id
  AND (:lookback_hours = -1 OR sql_exec_start > SYSDATE - (:lookback_hours/24) OR vsm.status = 'EXECUTING')
  AND vs.sql_text NOT LIKE '%dm_perf%'
GROUP BY vsm.sql_id, vsm.sql_plan_hash_value
ORDER BY count(*) ASC;

set verify on
set feedback on
