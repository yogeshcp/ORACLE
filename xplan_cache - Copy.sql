accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(13);
exec :sqlid := '&sqlid_in';

accept child_number_in default '' prompt 'Enter Child Number [Default is to display all children]: '
var child_number varchar2(13);
exec :child_number := '&child_number_in';

@screen_setup
column plan_data format a150;
column ord format 999;

column cost format 99999;
col buffer_gets format 999,999,999
set heading off;
set feedback off;
SELECT 'SQL_ID: ' || :sqlid || ', CHILD NUMBER: ' || :child_number FROM dual;
prompt
SELECT vst.sql_text FROM v$sqltext vst where vst.sql_id = :sqlid ORDER BY vst.piece;
prompt
SELECT 'PLAN HASH VALUE: ' || vs.plan_hash_value FROM v$sql vs WHERE vs.sql_id = :sqlid AND vs.child_number = :child_number;
prompt
set heading on;
column operation format a39
SELECT /* max trick to reverse order */ MAX(y.rn) over () - y.rn + 1 AS ord, substr(lpad(' ', y.depth)||y.operation||' '||y.options, 1, 39) AS operation, y.name, y.starts, y.erows, y.cost, y.etime, y.arows, y.atime, y.buffer_gets--, y.disk_reads
--,SUBSTR(x.plan_table_output, 1, 150) AS plan_data--
FROM
--(SELECT plan_table_output FROM TABLE(dbms_xplan.display_cursor(:sqlid, :child_number, 'IOSTATS ADVANCED LAST -BYTES +PEEKED_BINDS -PROJECTION -ALIAS'))) x,
(SELECT a.id, ROWNUM AS rn, a.depth, a.operation, a.options, a.name, a.starts, a.erows, a.cost, a.etime, a.arows, a.atime, a.buffer_gets, a.disk_reads
  FROM (SELECT vspsa.id, vspsa.parent_id,
               vspsa.depth, vspsa.operation, vspsa.options, vspsa.object_name as name, vspsa.last_starts as starts, vspsa.cardinality as erows, vspsa.cost, vspsa.time as etime,
               vspsa.last_output_rows as arows, vspsa.last_elapsed_time/1000000 as atime,
               vspsa.last_cr_buffer_gets+vspsa.last_cu_buffer_gets as buffer_gets, vspsa.last_disk_reads as disk_reads
        FROM v$sql_plan_statistics_all vspsa
        WHERE vspsa.sql_id = :sqlid
        AND vspsa.child_number = :child_number) a
  START WITH a.id = 0
  CONNECT BY PRIOR a.id = a.parent_id
  ORDER siblings BY a.id DESC) y
ORDER BY y.id;
--WHERE y.id (+) = CASE WHEN regexp_like(x.plan_table_output, '^\|[\* 0-9]+\|')
                      --THEN to_number(regexp_substr(x.plan_table_output, '[0-9]+')) END;

COLUMN access_predicates format a75;
COLUMN filter_predicates format a75;
SELECT access_predicates, filter_predicates FROM v$sql_plan_statistics_all WHERE sql_id = :sqlid AND child_number = :child_number;

@sql_stats_query