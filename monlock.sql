@screen_setup

col inst format 9999;
col session_id format 9999999;
col owner format a12;
col osuser format a10;
col pid format a12;
col lock_held format a14;
col lock_req format a14;
select s.inst_id as inst, s.sid as session_id, s.schemaname as owner, o.object_name, s.osuser, s.process as pid,
       decode(v.lmode, 1, 'null', 2, 'row share', 3, 'row exclusive', 4, 'share', 5, 'share row excl', 6, 'exclusive') as lock_held,
       decode(v.request, 1, 'null', 2, 'row share', 3, 'row exclusive', 4, 'share', 5, 'share row excl', 6, 'exclusive') as lock_req,
       v.ctime, s.blocking_session as blocking_sid
FROM gv$lock v, all_objects o, gv$session s
WHERE v.id1 = o.object_id
and o.object_name not like 'V$*'
and o.object_type != 'EDITION'
and v.sid = s.sid
and v.inst_id = s.inst_id
and s.schemaname != 'SYS'
and o.temporary != 'Y'
and (s.audsid != userenv('sessionid') or o.owner != 'SYS' or v.lmode != 4)
ORDER BY v.lmode, v.ctime desc;