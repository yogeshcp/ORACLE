@screen_setup
set recsep off
set newpage 0
accept uname_in default 'V500' prompt 'Enter Owner [V500]: '
accept tname_in  prompt 'Enter Table Name: '

var t_name varchar2(30);
var u_name varchar2(30);

exec :u_name := trim(upper('&uname_in'));
exec :t_name := trim(upper('&tname_in'));

column table_owner format a15
column table_name format a30
column index_name format a30
column column_name format a30
break on index_name skip 1 on uniqueness
SELECT di.uniqueness, dic.index_name, dic.column_name
FROM dba_ind_columns dic, dba_indexes di
WHERE dic.table_owner = :u_name
  AND dic.table_name = :t_name
  AND dic.index_name = di.index_name
  AND dic.table_name = di.table_name
  AND dic.table_owner = di.table_owner
ORDER BY di.uniqueness, dic.index_name, dic.column_position;
set verify on
clear breaks
