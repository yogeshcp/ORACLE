@screen_setup
WITH locks AS (SELECT /*+ MATERIALIZE */ sid, count(*) AS lock_count, max(ctime) AS max_lock_sec
               FROM gv$lock
               WHERE type NOT IN ('AE', 'MR')
               GROUP BY sid)
     ,sessions AS (SELECT /*+ MATERIALIZE */ gvs.inst_id, gvs.sid, gvs.osuser, gvs.process, gvs.program, gvs.blocking_session,
                         decode(gvs.row_wait_obj#, -1, decode(gvs.p2text, 'object #', gvs.p2, gvs.row_wait_obj#), gvs.row_wait_obj#) as blocked_object
                   FROM gv$session gvs)
SELECT blocker_sessions.sid as blocking_sid
       ,blocker_sessions.inst_id
       ,substr(blocker_sessions.osuser, 1, 10) as os_user
       ,substr(blocker_sessions.process, 1, 15) as process
       ,substr(blocker_sessions.program, 1, 35) as program
       ,locks.lock_count-1 as locks_held
       ,locks.max_lock_sec as max_lock_time
       ,count(blocked_sessions.sid) as block_session_cnt
       ,substr(do.object_name, 1, 30) as object_name
FROM sessions blocked_sessions, sessions blocker_sessions, locks, dba_objects do
WHERE blocked_sessions.blocking_session IS NOT NULL
AND blocker_sessions.sid = blocked_sessions.blocking_session
AND locks.sid = blocker_sessions.sid
AND do.object_id (+) = blocked_sessions.blocked_object
GROUP BY blocker_sessions.sid, blocker_sessions.inst_id, blocker_sessions.osuser, blocker_sessions.process, blocker_sessions.program, locks.lock_count, locks.max_lock_sec, do.object_name;