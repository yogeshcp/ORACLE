--:sqlid variable must be set before calling sql_stats_query
@screen_setup
Prompt Stats in the Dictionary Cache
WITH bases AS (SELECT /*+ MATERIALIZE */ signature, sql_handle FROM dba_sql_plan_baselines WHERE accepted = 'YES' and enabled = 'YES')
SELECT /* <dm_perf.sql_stats_query> */ inst_id, :sqlid AS sql_id, plan_hash, child_cnt, (SELECT child_number FROM v$sql WHERE child_address = last_active_child_address and sql_id = :sqlid) AS last_child_num,
       execs, etime, avg_etime, disk_reads, avg_disk, buffer_gets, avg_buffer, avg_rows, baseline AS b, substr(optimizer,1,1) AS o
FROM (SELECT a.inst_id, :sqlid sql_id, a.plan_hash_value AS plan_hash, loaded_versions AS child_cnt, last_active_child_address, a.executions execs, a.elapsed_time/1000000 etime,
(a.elapsed_time/1000000)/decode(nvl(a.executions,0),0,1,a.executions) avg_etime,
a.disk_reads, a.disk_reads/decode(nvl(a.executions,0),0,1,a.executions) avg_disk,
a.buffer_gets, a.buffer_gets/decode(nvl(a.executions,0),0,1,a.executions) avg_buffer, 
a.rows_processed, a.rows_processed/decode(nvl(a.executions,0),0,1,a.executions) as avg_rows,
decode(nvl(b.sql_handle, 'NULL'), 'NULL', '', '*') AS baseline, a.optimizer_mode optimizer
FROM gv$sqlarea_plan_hash a, bases b
WHERE a.sql_id = :sqlid
AND a.exact_matching_signature = b.signature (+));