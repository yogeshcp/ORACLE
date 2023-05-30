@screen_setup
col script format a80
select /*+ <dm_perf.find_awr> */ sql_id,
       substr(to_char(SUBSTR(SQL_TEXT, REGEXP_INSTR(SQL_TEXT,'<',1)+1,
              (REGEXP_INSTR(SQL_TEXT,'>',1)-REGEXP_INSTR(SQL_TEXT,'<',1)-1))),1,80) SCRIPT
from dba_hist_sqltext
where  (lower(sql_text) like lower('%&search_string%') and sql_text not like '%dm_perf%')
order by 1;
set verify on
