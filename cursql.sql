@screen_setup
col sid_serial format a16
col sql_text format a42
col prl format a4
break on inst_id
WITH sess AS (SELECT /*+ <dm_perf.cursql> materialize */ gvs.sid, gvs.sql_id, gvs.sql_child_number, gvs.paddr, gvs.inst_id, gvs.machine, gvs.osuser, gvs.process,
              gvs.serial#, (sysdate-gvs.sql_exec_start)*24*60*60 as elapsed_seconds, (select count (*) from gv$px_session gvps where gvps.qcsid = gvs.sid and gvps.qcsid != gvps.sid) as parallel_count
              FROM gv$session gvs WHERE (gvs.status = 'ACTIVE' AND gvs.sid NOT IN (SELECT gvps.sid FROM gv$px_session gvps where gvps.sid != gvps.qcsid /* Exclude parallel slaves */))
                                 OR gvs.sid IN (SELECT gvps.sid FROM gv$px_session gvps WHERE gvps.sid = gvps.qcsid /* Include parallel coordinator */)),
     proc AS (SELECT /*+ <dm_perf.cursql> materialize */ spid, addr, inst_id FROM gv$process),
     sql AS (SELECT /*+ <dm_perf.cursql> materialize */ sql_id, sql_text, child_number, inst_id FROM gv$sql where users_executing > 0)
SELECT /* <dm_perf.cursql> */ substr(sess.inst_id, 1, 4) as inst, substr(sess.machine,1,30) as machine, substr(sess.osuser, 1, 10) as os_user,
       substr(sess.process, 1, 15) as process, substr(proc.spid,1,6) as spid,
       ''''||sess.sid||','||sess.serial#||',@'||sess.inst_id||'''' as sid_serial, decode(sess.parallel_count, 0, null, 'px'||sess.parallel_count) as prl,
       elapsed_seconds as elapsed, substr(sql.sql_id, 1, 13) as sql_id,
       substr(sql.sql_text, 1, 42) as sql_text
FROM sess, proc, sql
WHERE sess.sql_id = sql.sql_id
      and sess.sql_child_number = sql.child_number
      and sess.inst_id = sql.inst_id
      and sess.paddr = proc.addr
      and sess.inst_id = proc.inst_id
      and sql.sql_text not like '%dm_perf%'
ORDER BY elapsed_seconds desc, sess.inst_id;
clear breaks
