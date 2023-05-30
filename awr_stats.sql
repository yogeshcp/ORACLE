accept sqlid_in  prompt 'Enter SQL_ID: '
var sqlid varchar2(30);
exec :sqlid := trim('&sqlid_in');

Prompt Stats for &sqlid_in in Workload Repository
@screen_setup
select stat.snap_id,
       to_char(dhs.begin_interval_time, 'DD-MON-YYYY HH24:MI') as snap_start_time,
       stat.plan_hash_value as plan_hash,
       stat.optimizer_mode as optimizer,
       sum(stat.executions_delta) as execs_dlt,
       sum(elapsed_time_delta / 1000000.0) as elap_dlt,
       to_char(substr(text.sql_text, regexp_instr(text.sql_text,'<',1)+1,(regexp_instr(text.sql_text,'>',1)-regexp_instr(text.sql_text,'<',1)-1))) as script
from dba_hist_sqlstat stat, dba_hist_sqltext text, dba_hist_snapshot dhs
where stat.sql_id = text.sql_id
      and stat.dbid   = text.dbid
      and stat.dbid = dhs.dbid
      and stat.snap_id = dhs.snap_id
      and stat.instance_number = dhs.instance_number
      and stat.sql_id = :sqlid
group by stat.snap_id, to_char(dhs.begin_interval_time, 'DD-MON-YYYY HH24:MI'), stat.plan_hash_value, stat.optimizer_mode, to_char(substr(text.sql_text, regexp_instr(text.sql_text,'<',1)+1,(regexp_instr(text.sql_text,'>',1)-regexp_instr(text.sql_text,'<',1)-1)))
order by stat.snap_id, to_char(dhs.begin_interval_time, 'DD-MON-YYYY HH24:MI');
