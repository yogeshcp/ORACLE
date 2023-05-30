@screen_setup
prompt The results of this first query are applicable to database on Oracle 11.1 and have not taken CWxPI 1980
select vsa.sql_id, nvl(to_char(substr(vsa.sql_text, regexp_instr(vsa.sql_text,'<',1)+1, (regexp_instr(vsa.sql_text,'>',1)-regexp_instr(vsa.sql_text,'<',1)-1))), substr(vsa.sql_text, 1, 50)) script, vsa.loaded_versions, vsa.executions
from v$sqlarea vsa
where vsa.loaded_versions > 500 order by vsa.loaded_versions asc;

prompt The results of this first query are applicable to Oracle 11.2+ and Oracle 11.1 with CWxPI 1980
select vs.sql_id, nvl(to_char(substr(vs.sql_text, regexp_instr(vs.sql_text,'<',1)+1,
(regexp_instr(vs.sql_text,'>',1)-regexp_instr(vs.sql_text,'<',1)-1))), substr(vs.sql_text, 1, 50)) script,
count(*) as cnt, sum(vs.executions) as executions
from v$sql vs
where vs.is_obsolete = 'N'
group by vs.sql_id, nvl(to_char(substr(vs.sql_text, regexp_instr(vs.sql_text,'<',1)+1, (regexp_instr(vs.sql_text,'>',1)-regexp_instr(vs.sql_text,'<',1)-1))), substr(vs.sql_text, 1, 50))
having count(*) > 500
order by count(*) asc;


prompt scripts listed above should be evaluated as to whether a
prompt grant execute or baselines should be used to prevent parsing issues with the query.
prompt An Oracle patch has been published by Cerner that resolves the known issue with ACS and high cursor counts.
