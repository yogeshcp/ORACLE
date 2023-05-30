@screen_setup

WITH parsing AS (SELECT vash.session_id, vash.session_serial#, vash.sql_id, vash.sample_time, ROW_NUMBER () OVER (ORDER BY vash.sample_time) - ROW_NUMBER () OVER (PARTITION BY vash.session_id, vash.session_serial#, vash.sql_id ORDER BY vash.sample_time) as grp
FROM v$active_session_history vash
WHERE vash.in_hard_parse = 'Y'),
     long_parses AS (SELECT p.session_id as sid, p.session_serial# as serial#, p.sql_id, COUNT(*) AS snap_count, to_char(MIN(p.sample_time), 'DD-MON-YYYY HH24:MI:SS') AS first_snap, to_char(MAX(p.sample_time), 'DD-MON-YYYY HH24:MI:SS') AS last_snap
FROM parsing p
GROUP BY p.session_id, p.session_serial#, p.sql_id, p.grp
HAVING COUNT(*) > 15)
SELECT lp.snap_count, lp.sid, lp.serial#, lp.sql_id, lp.first_snap, lp.last_snap, vs.process, vs.program, vs.terminal, vs.machine, vs.osuser, vs.username, vsa.sql_text
FROM long_parses lp, v$session vs, v$sqlarea vsa
WHERE lp.sid = vs.sid
  AND lp.serial# = vs.serial#
  AND vs.sql_id = vsa.sql_id
ORDER BY lp.snap_count DESC;
