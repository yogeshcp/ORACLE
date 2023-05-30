DEFINE in_sql_id = '&sql_id'
DEFINE in_plan_hash = &plan_hash_value

set recsep off
@screen_setup
set newpage 0


prompt Displaying TABLE STATS Data

select ut.table_name,
   ut.avg_row_len
  ,ut.blocks
  ,ut.num_rows
from dba_tables ut
where ut.table_name in (select object_name from v$sql_plan where sql_id =  '&&in_sql_id' and plan_hash_value = &&in_plan_hash)
order by ut.table_name;

prompt Displaying COLUMN STATS

select ut.table_name,ut.column_name,ut.avg_col_len,trunc(ut.density,9) as density,
  ut.num_distinct,ut.num_nulls,ut.histogram
from dba_tab_columns ut
where (table_name,column_name)in (select table_name,column_name from dba_ind_columns where index_name in (
select object_name from v$sql_plan where sql_id =  '&&in_sql_id' and plan_hash_value = &&in_plan_hash))
order by ut.table_name,ut.column_name;


prompt Displaying INDEX Data

col object_name format a30;

select ui.table_name,ui.index_name,
   ui.avg_data_blocks_per_key as avgdblk
  ,ui.avg_leaf_blocks_per_key as avglblk
  ,ui.clustering_factor as clstfct
  ,ui.blevel
  ,ui.distinct_keys as numdist
  ,ui.leaf_blocks as numblks
  ,ui.num_rows from dba_indexes ui
where ui.index_name in (select object_name from v$sql_plan where sql_id =  '&&in_sql_id' and plan_hash_value = &&in_plan_hash)
order by ui.table_name,ui.index_name;


prompt Displaying HIGH/LOW Data

col column_name format a30;
col a_low_value format a32;
col low_value format a32;
col high_value format a32;
col a_high_value format a40;

select table_name,column_name,low_value,high_value
  from
  (select table_name,column_Name
   ,(case
       when data_type = 'DATE' then to_char(v500.dm_dbms_stats.boil_raw_to_date(low_value),'DD-MON-YYYY HH24:MI:SS')
       when data_type IN ('NUMBER', 'FLOAT') THEN to_char(v500.dm_dbms_stats.boil_raw_to_number(low_value) )
       when data_type in ('CHAR', 'VARCHAR', 'VARCHAR2') then rpad(v500.dm_dbms_stats.boil_raw_to_text(low_value),15)
     end) low_value
   ,(case
       when data_type = 'DATE' then to_char(v500.dm_dbms_stats.boil_raw_to_date(high_value),'DD-MON-YYYY HH24:MI:SS')
       when data_type IN ('NUMBER', 'FLOAT') THEN to_char(v500.dm_dbms_stats.boil_raw_to_number(high_value) )
       when data_type in ('CHAR', 'VARCHAR', 'VARCHAR2') then rpad(v500.dm_dbms_stats.boil_raw_to_text(high_value),15)
     end) high_value
   from dba_Tab_columns where (table_name,column_name)in (select table_name,column_name from dba_ind_columns where index_name in (
select object_name from v$sql_plan where sql_id =  '&&in_sql_id' and plan_hash_value = &&in_plan_hash)))
order by table_name,column_name;


