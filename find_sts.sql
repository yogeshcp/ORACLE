@screen_setup
set lines 160
set pages 999
col script format a65
select /*+ <dm_perf.find_sts> */ sql_id, SQLSET_NAME, substr(SQLSET_OWNER,1,8) owner, plan_hash_value, executions, elapsed_time/1000000/executions Avg_Sec,
       nvl(to_char(SUBSTR(SQL_TEXT, REGEXP_INSTR(SQL_TEXT,'<',1)+1,
              (REGEXP_INSTR(SQL_TEXT,'>',1)-REGEXP_INSTR(SQL_TEXT,'<',1)-1))), substr(sql_text, 1, 50)) SCRIPT
from dba_sqlset_statements
where  (lower(sql_text) like lower('%&search_string%') and sql_text not like '%dm_perf%')
order by 2,7,4;
set verify on

