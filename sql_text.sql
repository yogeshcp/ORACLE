@screen_setup
col SQL_FULLTEXT format a155
select sql_fulltext from v$sqlarea where sql_id = '&sql_id';
set verify on
