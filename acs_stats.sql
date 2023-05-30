@screen_setup
col sql_text for a80
break on sql_id skip 1
select sql_id, plan_hash_value, executions, parse_calls, last_load_time, bfg_per_exec_per_rows, decode(length(script), length(sql_text), substr(sql_text, 1, 45), script) as script
from
(select sql_id, plan_hash_value, executions, parse_calls, last_load_time,
      (buffer_gets/decode(executions,0,1,executions))/decode(rows_processed,0,1,rows_processed) as bfg_per_exec_per_rows,
      regexp_replace(sql_text, '.+CCL<(.+)> \*/.+', '\1', 1, 1) as script,
      sql_text
from v$sqlarea_plan_hash
where parsing_schema_name != 'SYS'
and sql_id in (select sql_id from v$sqlarea_plan_hash where plan_hash_value > 0 group by sql_id, sql_text having count(distinct plan_hash_value) >= 2))
order by sql_id, last_load_time;
clear breaks