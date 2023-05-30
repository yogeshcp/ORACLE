@screen_setup
col plan_hash format a10
col sql_handle format a25
Prompt Accepted Baselines
select dspb.sql_handle, dspb.plan_name,
       substr(dspb.sql_text,
              regexp_instr(dspb.sql_text,'<',1)+1,
              (regexp_instr(dspb.sql_text,'>',1)-regexp_instr(dspb.sql_text,'<',1)-1)
             ) script,
       enabled, accepted,
       lower(regexp_replace(dspb.description, '.*SQL_ID:(.*) PLAN_HASH_VALUE.*', '\1')) as sql_id,
       lower(regexp_replace(dspb.description, '.*PLAN_HASH_VALUE:([[:digit:]]*).*', '\1')) as plan_hash
from dba_sql_plan_baselines dspb
order by dspb.sql_handle, dspb.plan_name;
