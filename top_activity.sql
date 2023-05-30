col waiter format a20;
col sample_time format a11;
col wait_graph format a100;
WITH ash_data AS
(SELECT to_char(ash.sample_time,'HH24:MI:SS') AS sample_time,
 decode(ash.session_state,'ON CPU', 'C',
        decode(ash.wait_class, 'Administrative', 'D',
                               'Application', 'A',
                               'Cluster', 'L',
                               'Commit', 'C',
                               'Concurrency', 'R',
                               'Configuration', 'F',
                               'Idle', 'I',
                               'Network', 'N',
                               'Other', 'O',
                               'Queueing', 'Q',
                               'Scheduler', 'K',
                               'System I/O', 'S',
                               'User I/O', 'U')) as waiter,
 sample_id
FROM v$active_session_history ash
WHERE sample_time BETWEEN (select max(sample_time)-5/60/60/24 from v$active_session_history) and (select max(sample_time) from v$active_session_history)),
colors AS (
SELECT chr(27)||'[1;31m' as red_highlight,
       chr(27)||'[2;31m' as light_red_highlight,
       chr(27)||'[1;32m' as green_highlight,
       chr(27)||'[2;32m' as light_green_highlight,
       chr(27)||'[1;34m' as blue_highlight,
       chr(27)||'[2;32m' as light_green_highlight,
       chr(27)||'[m' as default_highlight
FROM dual),
graph_data_d AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'D' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_a AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'A' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_l AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'L' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_c AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'C' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_r AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'R' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_f AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'F' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_i AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'I' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_n AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'N' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_o AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'O' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_q AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'Q' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_k AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'K' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_s AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'S' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_u AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'U' GROUP BY sample_time, waiter ORDER BY sample_time, waiter)
SELECT d. from graph_data_d d,
              graph_data_a a,
              graph_data_l l,
              graph_data_c c,
              graph_data_r r,
              graph_data_f f,
              graph_data_i i,
              graph_data_n n,
              graph_data_o o,
              graph_data_q q,
              graph_data_k k,
              graph_data_s s,
              graph_data_u u
              col waiter format a20;
col sample_time format a11;
col wait_graph format a100;
WITH ash_data AS
(SELECT to_char(ash.sample_time,'HH24:MI:SS') AS sample_time,
 decode(ash.session_state,'ON CPU', 'C',
        decode(ash.wait_class, 'Administrative', 'D',
                               'Application', 'A',
                               'Cluster', 'L',
                               'Commit', 'C',
                               'Concurrency', 'R',
                               'Configuration', 'F',
                               'Idle', 'I',
                               'Network', 'N',
                               'Other', 'O',
                               'Queueing', 'Q',
                               'Scheduler', 'K',
                               'System I/O', 'S',
                               'User I/O', 'U')) as waiter,
 sample_id
FROM v$active_session_history ash
WHERE sample_time BETWEEN (select max(sample_time)-5/60/60/24 from v$active_session_history) and (select max(sample_time) from v$active_session_history)),
colors AS (
SELECT chr(27)||'[1;31m' as red_highlight,
       chr(27)||'[2;31m' as light_red_highlight,
       chr(27)||'[1;32m' as green_highlight,
       chr(27)||'[2;32m' as light_green_highlight,
       chr(27)||'[1;34m' as blue_highlight,
       chr(27)||'[2;32m' as light_green_highlight,
       chr(27)||'[m' as default_highlight
FROM dual),
graph_data_d AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'D' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_a AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'A' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_l AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'L' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_c AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'C' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_r AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'R' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_f AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'F' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_i AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'I' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_n AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'N' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_o AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'O' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_q AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'Q' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_k AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'K' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_s AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'S' GROUP BY sample_time, waiter ORDER BY sample_time, waiter),
graph_data_u AS (SELECT sample_time, rpad(' ', count(sample_id), waiter) as wait_graph FROM ash_data WHERE waiter = 'U' GROUP BY sample_time, waiter ORDER BY sample_time, waiter)
SELECT * from graph_data_d d,
              graph_data_a a,
              graph_data_l l,
              graph_data_c c,
              graph_data_r r,
              graph_data_f f,
              graph_data_i i,
              graph_data_n n,
              graph_data_o o,
              graph_data_q q,
              graph_data_k k,
              graph_data_s s,
              graph_data_u u
WHERE d.sample_time = a.sample_time
AND a.sample_time = l.sample_time
AND l.sample_time = c.sample_time
AND c.sample_time = r.sample_time
AND r.sample_time = i.sample_time
AND i.sample_time = n.sample_time
AND n.sample_time = o.sample_time
AND o.sample_time = q.sample_time
AND q.sample_time = k.sample_time
AND k.sample_time = s.sample_time
AND s.sample_time = u.sample_time;