@screen_setup
select sql_text from dba_hist_sqltext where sql_id = '&sql_id';
set verify on
