accept lookback_hours_in default 0 prompt 'Hours to look back, supplying -1 for all data available [0, displaying currently running longops]: '
var lookback_hours number;
exec :lookback_hours := '&lookback_hours_in';

@screen_setup
column OPERATION format a15
column TARGET format a30
column SCRIPT format a45
column pct format 999
column seconds format 99999
SELECT decode(a.OPNAME,'Index Fast Full Scan','Index FFS',a.OPNAME) as OPERATION,
       a.TARGET,
       a.sofar/a.totalwork*100 as pct,
       a.ELAPSED_SECONDS as seconds,
       to_char(a.start_time,'dd-Mon-yy hh24:mi:ss') as Started,
       decode(a.time_remaining, 0, 'Completed', to_char(sysdate+(a.time_remaining/24/60/60),'DD-MON-YY HH24:MI:SS')) as est_completion,
       a.SQL_ID,
       SUBSTR(b.SQL_TEXT, REGEXP_INSTR(b.SQL_TEXT,'<',1)+1,(REGEXP_INSTR(b.SQL_TEXT,'>',1)-REGEXP_INSTR(b.SQL_TEXT,'<',1)-1)) SCRIPT
FROM   v$session_longops a, dba_hist_sqltext b
WHERE  a.sql_id = b.sql_id (+)
AND    (:lookback_hours = -1 OR a.start_time > sysdate - (:lookback_hours/24) OR a.totalwork != a.sofar)
AND    OPNAME not like 'RMAN%'
ORDER BY a.time_remaining asc, a.start_time asc;
