@screen_setup
col script format a50
col start_time format a10
col Sid_Serial format a17
col elapsed format 999999
set feedback off
SELECT /* <dm_perf.monsql_query> */ substr(vsm.status,1,4) as status,
       ''''||vsm.sid||', '||vsm.session_serial#||', @'||vsm.inst_id||'''' as "Sid_Serial",
       vsm.sql_id, decode(vs.sql_plan_baseline, null, null,'*') as b,
       decode(instr(vs.sql_text, ':O1:'), 0, ' ', '*') as g,
       vsm.sql_plan_hash_value as plan_hash,
       to_char(vsm.sql_exec_start,'HH24:MI:SS') as start_time,
       vsm.elapsed_time/1000000 as seconds,
       vsm.buffer_gets,
       vsm.disk_reads,
       nvl(to_char(substr(vs.sql_text, regexp_instr(vs.sql_text,'<',1)+1, (regexp_instr(vs.sql_text,'>',1)-regexp_instr(vs.sql_text,'<',1)-1))), substr(vs.sql_text, 1, 50)) as script
FROM gv$sql_monitor vsm, gv$sqlarea vs
WHERE vsm.sql_id = vs.sql_id
  AND vsm.inst_id = vs.inst_id
  AND (:lookback_hours = -1 OR sql_exec_start > SYSDATE - (:lookback_hours/24) OR vsm.status = 'EXECUTING')
  AND vs.sql_text NOT LIKE '%dm_perf%'
  AND (:search_string = 'DM_PERF_NOFILTER' OR vs.sql_text LIKE '%'||:search_string||'%')
ORDER BY
  CASE :sorter
  WHEN 'MONSQL' THEN substr(vsm.status,1,4)||vsm.sql_exec_start||vsm.elapsed_time
  WHEN 'MONSQLSORT' THEN vs.sql_text||vsm.sql_id||vsm.status||vsm.sql_exec_start||vsm.elapsed_time
  END;
set verify on
set feedback on
