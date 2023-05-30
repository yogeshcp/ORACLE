--Query for multiple sqlid with same phv, trying to find items hard parsing when they should be using binds
SELECT COUNT(*),
       SUM(vsph.sharable_mem) AS mem_usage,
       MIN(vsph.sql_id) AS example_sql_id,
       vsph.plan_hash_value AS plan_hash,
       parsing_schema_name,
            MIN(NVL(TO_CHAR(SUBSTR(vsph.sql_text, regexp_instr(vsph.sql_text,'<',1)+1, (regexp_instr(vsph.sql_text,'>',1)-regexp_instr(vsph.sql_text,'<',1)-1))), SUBSTR(vsph.sql_text, 1, 45))) as script
FROM v$sql vsph
WHERE vsph.sql_text NOT LIKE '%dm_perf.find_sql%'
  AND vsph.plan_hash_value != 0
GROUP BY vsph.plan_hash_value, PARSING_SCHEMA_NAME
HAVING COUNT(*) > 10
ORDER BY count(*) ASC;
