@screen_setup
col plan_hash format a10
Prompt Accepted Baselines
select dspb.plan_name,
       substr(dspb.sql_text,
              regexp_instr(dspb.sql_text,'<',1)+1,
              (regexp_instr(dspb.sql_text,'>',1)-regexp_instr(dspb.sql_text,'<',1)-1)
             ) script,
       dspb.enabled, dspb.accepted, to_char(dspb.last_executed,'DD/MM/YYYY HH24:MI:SS') last_exec,
       lower(regexp_replace(dspb.description, '.*SQL_ID:(.*) PLAN_HASH_VALUE.*', '\1')) as sql_id,
       lower(regexp_replace(dspb.description, '.*PLAN_HASH_VALUE:([[:digit:]]*).*', '\1')) as plan_hash
from dba_sql_plan_baselines dspb where dspb.accepted='YES'
order by dspb.last_executed;
