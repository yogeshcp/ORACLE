accept lookback_minutes_in default 5 prompt 'Minutes to look back, supplying -1 for all ASH data [5]: '
var lookback_minutes number;
exec :lookback_minutes := '&lookback_minutes_in';

@screen_setup
--length of ACTIVITY is 53 due to 10 chars for each color (30 chars) + 20 chars for all letters + 3 chars to handle if each letter got rounded up
col ACTIVITY format a53
col sys_pct format 999.99
col cpu_pct like sys_pct
col io_pct like sys_pct
col LAST_SAMPLE format a25
col SCRIPT format a45 wrapped
col BG_PER_EX format 9999999.99
col ELA_PER_EX format 99999.9999
col EXECS format 999999999
set recsep off;
SELECT chr(27)||'[1;34m'||'USER IO Waits'||chr(27)||'[m' as "Color Key" FROM dual UNION
SELECT chr(27)||'[1;32m'||'CPU + CPU Waiting'||chr(27)||'[m' FROM dual UNION
SELECT chr(27)||'[1;31m'||'OTHER Waits'||chr(27)||'[m' FROM dual;

SELECT /* <dm_perf.top_query> */ sql_id, ELA_PER_EX, BG_PER_EX, EXECS, B, G, script, &1, activity
FROM (
  SELECT sql_id, ELA_PER_EX, BG_PER_EX, EXECS, B, G, script, &1, activity--, lag(&1) over (order by &2) as lagged, lag(&1, 2) over (order by &2) as lagged2
  FROM (
    SELECT x.sql_id,cpu,io,total,other,
           (v.elapsed_time/1000000)/(DECODE(v.executions,0,1,v.executions)) AS ELA_PER_EX,
           (v.buffer_gets)/(DECODE(v.executions,0,1,v.executions)) AS BG_PER_EX,
           v.executions as EXECS,
           decode(v.sql_plan_baseline, NULL, NULL,'*') as B,
           decode(v.sql_text, null, null, decode(instr(v.sql_text, ':O1:'), 0, ' ', '*')) as G,
           replace(replace(substr(nvl(to_char(substr(v.sql_text, regexp_instr(v.sql_text,'<',1)+1, (regexp_instr(v.sql_text,'>',1)-regexp_instr(v.sql_text,'<',1)-1))), substr(v.sql_text, 1, 45)), 1, 45), chr(10), ' '), chr(13), ' ') AS script,
           x.total/sum(x.total) over ()*100 as sys_pct,
           x.cpu/sum(x.cpu) over ()*100 as cpu_pct,
           x.io/sum(x.io) over ()*100 as io_pct,
           CASE WHEN x.cpu >= x.other AND x.other >= x.io THEN green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight||
                                                               red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight||
                                                               blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight
                WHEN x.cpu >= x.io AND x.io >= x.other THEN    green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight||
                                                               blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight||
                                                               red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight
                WHEN x.other >= x.io AND x.io >= x.cpu THEN    red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight||
                                                               blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight||
                                                               green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight
                WHEN x.other >= x.cpu AND x.cpu >= x.io THEN   red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight||
                                                               green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight||
                                                               blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight
                WHEN x.io >= x.cpu AND x.cpu >= x.other THEN   blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight||
                                                               green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight||
                                                               red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight
                WHEN x.io >= x.other AND x.other >= x.cpu THEN blue_highlight||trim(rpad(' ', round(IO_PERCENT/5)+1, 'U'))||default_highlight||
                                                               red_highlight||trim(rpad(' ', round(OTHER_PERCENT/5)+1, 'E'))||default_highlight||
                                                               green_highlight||trim(rpad(' ', round(CPU_PERCENT/5)+1, 'C'))||default_highlight
                ELSE 'NO DATA' END as ACTIVITY
    FROM (
      SELECT chr(27)||'[1;32m' as green_highlight,
             chr(27)||'[1;31m' as red_highlight,
             chr(27)||'[1;34m' as blue_highlight,
             chr(27)||'[m' as default_highlight,
             ash.SQL_ID,
             SUM(DECODE(ash.session_state,'ON CPU',1,0)) AS "CPU",
             SUM(DECODE(ash.session_state,'WAITING',1,0)) - SUM(DECODE(ash.session_state,'WAITING', DECODE(ash.wait_class, 'User I/O',1,0),0)) AS "OTHER" ,
             SUM(DECODE(ash.session_state,'WAITING', DECODE(ash.wait_class, 'User I/O',1,0),0)) AS "IO" ,
             SUM(1) AS "TOTAL",
             SUM(DECODE(ash.session_state,'ON CPU',1,0)) / SUM(1) * 100 as "CPU_PERCENT",
             SUM(DECODE(ash.session_state,'WAITING', DECODE(ash.wait_class, 'User I/O',1,0),0)) / SUM(1) * 100 AS "IO_PERCENT",
             (SUM(1) - SUM(DECODE(ash.session_state,'ON CPU',1,0)) - SUM(DECODE(ash.session_state,'WAITING', DECODE(ash.wait_class, 'User I/O',1,0),0))) / SUM(1) * 100 AS "OTHER_PERCENT",
             TO_CHAR(MAX(ash.sample_time),'HH24:MI:SS') AS LAST_SAMPLE
      FROM v$active_session_history ash
      WHERE sql_id is not null
        AND (:lookback_minutes = -1 OR SAMPLE_TIME > SYSDATE - (:lookback_minutes/(24*60)))
      GROUP BY sql_id) x,
    v$sqlarea v
    WHERE x.sql_id = v.sql_id (+)
      AND v.sql_text (+) not like '%dm_perf%'
    ORDER BY &2 DESC)
  WHERE rownum <= 10
  ORDER BY &3 DESC);
set recsep wrapped;
