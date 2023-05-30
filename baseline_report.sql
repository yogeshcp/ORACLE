@screen_setup
col plan_hash_value format 9999999999
col plan_hash format a10
col etime format 99999.99
Prompt Baselines Currently in the Cache
WITH plans AS (
SELECT lower(regexp_replace(b.description, '.*PLAN_HASH_VALUE:([[:digit:]]*).*', '\1')) AS plan_hash_value,
       lower(regexp_replace(b.description, '.*SQL_ID:(.*) PLAN_HASH_VALUE.*', '\1')) AS sql_id,
       nvl(to_char(substr(b.sql_text, regexp_instr(b.sql_text,'<',1)+1, (regexp_instr(b.sql_text,'>',1)-regexp_instr(b.sql_text,'<',1)-1))), substr(b.sql_text, 1, 50)) AS script
FROM dba_sql_plan_baselines b
WHERE b.enabled='YES'
AND b.accepted='YES'),
sqls AS (
SELECT a.sql_plan_baseline, a.sql_id, max(child_number) as max_child, a.plan_hash_value, sum(a.executions) as executions, sum(a.elapsed_time)/1000000/decode(sum(a.executions), 0, null) as etime, to_char(max(a.last_active_time),'dd/mm/yyyy hh24:mi:ss') as last_active_time
FROM v$sql a
WHERE a.optimizer_mode != 'RULE'
GROUP BY a.sql_id, a.plan_hash_value, a.sql_plan_baseline)
SELECT s.sql_plan_baseline, s.sql_id, s.max_child, s.plan_hash_value, s.executions, s.etime, s.last_active_time, p.script
FROM sqls s, plans p
WHERE s.sql_id = p.sql_id
AND s.plan_hash_value = p.plan_hash_value
ORDER BY s.last_active_time;

Prompt Accepted + Enabled Baselines
SELECT dspb.plan_name,
       nvl(to_char(SUBSTR(dspb.sql_text, REGEXP_INSTR(dspb.sql_text,'<',1)+1, (REGEXP_INSTR(dspb.sql_text,'>',1)-REGEXP_INSTR(dspb.sql_text,'<',1)-1))), substr(dspb.sql_text, 1, 50)) AS script,
       dspb.enabled, dspb.accepted, to_char(dspb.last_executed,'dd/mm/yyyy hh24:mi:ss') last_exec,
       lower(regexp_replace(dspb.description, '.*SQL_ID:(.*) PLAN_HASH_VALUE.*', '\1')) as sql_id,
       lower(regexp_replace(dspb.description, '.*PLAN_HASH_VALUE:([[:digit:]]*).*', '\1')) as plan_hash
FROM dba_sql_plan_baselines dspb
WHERE dspb.accepted='YES'
AND dspb.enabled='YES'
ORDER BY dspb.last_executed;
