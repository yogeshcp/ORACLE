accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

accept child_number_in default '' prompt 'Enter Child Number [Default is to display all children]: '
var child_number varchar2(13);
exec :child_number := trim('&child_number_in');

@screen_setup
column plan_data format a155;
column ord format 999;
select max(rn) over () - y.rn + 1 as ord, substr(x.plan_table_output, 1, 155) as plan_data
from
(select plan_table_output from table(dbms_xplan.display_cursor(:sqlid, :child_number, 'IOSTATS ADVANCED +PEEKED_BINDS -PROJECTION -ALIAS -BYTES'))) x,
(select operation, options, object_name, access_predicates
        ,level, id, parent_id, position, rownum as rn
  from (select operation, options, object_name, access_predicates, id, parent_id, position from v$sql_plan where sql_id = :sqlid and child_number = :child_number) a
  start with id = 0
  connect by prior id = parent_id
  order siblings by id desc) y
where y.id (+) = case when regexp_like(x.plan_table_output, '^\|[\* 0-9]+\|')
                      then to_number(regexp_substr(x.plan_table_output, '[0-9]+')) end;

@sql_stats_query