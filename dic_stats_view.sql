accept oname_in default 'V500'  prompt 'Enter Table Owner [V500]: '
accept tname_in  prompt 'Enter Table Name: '

@screen_setup
set recsep off
set newpage 0
set feedback off
var o_name varchar2(30);
var t_name varchar2(30);
exec :t_name := trim(upper('&tname_in'));
exec :o_name := trim(upper('&oname_in'));

col blocks format 9,999,999,999
col expected_gather_date format a10 heading "EXPECTED|GATHER"
col last_gathered format a10 heading "LAST|GATHER"
col percent_stale format 999.99 heading "PERCENT|STALE"
col inserts like blocks
col updates like blocks
col deletes like blocks
prompt
prompt Displaying TABLE STATS Data for &tname_in
col stale format a5
select ut.table_name,
   ut.avg_row_len
  ,ut.blocks
  ,ut.num_rows
  ,(dtm.inserts+dtm.updates+dtm.deletes)/ut.num_rows*100.0 as percent_stale
  ,ut.stale_stats as stale
  ,dtm.inserts
  ,dtm.updates
  ,dtm.deletes
  ,to_char(ut.last_analyzed, 'MM/DD/YYYY') as last_gathered
  ,to_char(last_analyzed+((sysdate-last_analyzed)*10/((dtm.inserts+dtm.updates+dtm.deletes)/ut.num_rows*100.0)), 'MM/DD/YYYY') as expected_gather_date
from dba_tab_statistics ut, sys.dba_tab_modifications dtm
where ut.table_name = :t_name
and ut.table_name = dtm.table_name (+)
and ut.owner = dtm.table_owner (+)
and ut.owner = :o_name;

prompt
prompt Displaying COLUMN STATS Data for &tname_in
prompt
col buckets format a4
col low_value format a32;
col high_value format a32;
col hist format a5;
col nl format a4 heading "NULL|ABLE"
col avg_len format 9999 heading "AVG|LEN"
select ut.column_name,ut.avg_col_len as avg_len,trunc(ut.density,7) as density,
  ut.num_distinct,ut.num_nulls, nvl2(ddnc.column_name, 'NO', '') as nl,
  decode(ut.histogram, 'FREQUENCY', decode(ut.num_buckets, 0, '', ut.num_buckets), 'HEIGHT BALANCED', decode(ut.num_buckets, 0, '', 1, '', ut.num_buckets)) as buckets,
  decode(ut.histogram, 'FREQUENCY', 'FREQ', 'HEIGHT BALANCED', 'H-BAL', 'NONE', '', ut.histogram) as hist,
  (case
       when data_type = 'DATE' then to_char(dm_perf.boil_raw_to_date(low_value),'DD-MON-YYYY HH24:MI:SS')
       when data_type IN ('NUMBER', 'FLOAT') THEN to_char(dm_perf.boil_raw_to_number(low_value) )
       when data_type in ('CHAR', 'VARCHAR', 'VARCHAR2') then rpad(dm_perf.boil_raw_to_text(low_value),15)
     end) low_value
   ,(case
       when data_type = 'DATE' then to_char(dm_perf.boil_raw_to_date(high_value),'DD-MON-YYYY HH24:MI:SS')
       when data_type IN ('NUMBER', 'FLOAT') THEN to_char(dm_perf.boil_raw_to_number(high_value) )
       when data_type in ('CHAR', 'VARCHAR', 'VARCHAR2') then rpad(dm_perf.boil_raw_to_text(high_value),15)
     end) high_value
from dba_tab_columns ut
  left join v500.dm2_dba_notnull_cols ddnc
  on ut.table_name = ddnc.table_name
  and ut.owner = ddnc.owner
  and ut.column_name = ddnc.column_name
where ut.table_name = :t_name
and ut.owner = :o_name
order by ut.column_name;

prompt
prompt Displaying INDEX Data for &tname_in
col object_name format a30;
col clstfct format 99,999,999,999
col numdist format 99,999,999,999
col numblks format 9,999,999,999
col list heading ''
col uniqueness format a10
break on index_name skip 1
--This set lines is important to make the col_list wrap to the next line.  Do not change the column list in this query without taking this into account
set lines 141
WITH ind_columns AS
(SELECT table_owner, table_name, index_name, column_name, ROW_NUMBER () OVER (PARTITION BY table_owner, table_name, index_name ORDER BY column_position) AS rnum
FROM dba_ind_columns
WHERE table_name = :t_name
  AND table_owner = :o_name
ORDER BY column_position
),
col_list AS
(SELECT table_owner as owner, table_name, index_name, '-->'||LTRIM(SYS_CONNECT_BY_PATH(column_name, ', '), ', ') as list
FROM ind_columns
WHERE CONNECT_BY_ISLEAF = 1
START WITH rnum = 1
CONNECT BY rnum  = PRIOR rnum + 1
AND index_name = PRIOR index_name
ORDER BY rnum)
SELECT ui.index_name,
   ui.avg_data_blocks_per_key as avgdblk
  ,ui.avg_leaf_blocks_per_key as avglblk
  ,ui.clustering_factor as clstfct
  ,ui.blevel
  ,ui.distinct_keys as numdist
  ,ui.leaf_blocks as numblks
  ,ui.num_rows
  ,ui.uniqueness
  ,cl.list
FROM dba_indexes ui, col_list cl
WHERE ui.table_name = :t_name
  AND ui.owner = :o_name
  AND ui.owner = cl.owner
  AND ui.table_name = cl.table_name
  AND ui.index_name = cl.index_name
ORDER BY ui.index_name;
set feedback on
clear breaks