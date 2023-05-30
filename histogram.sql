@screen_setup
set feedback off
accept uname_in default 'V500' prompt 'Enter Owner [V500]: '
accept tname_in prompt 'Enter Table Name: '
accept cname_in prompt 'Enter Column Name: '
accept suppress_nonpopular_buckets_in default 'Y' prompt 'Do you want to suppress Non-Popular Buckets for Height Balanced Histograms? [Y]: '
var u_name varchar2(30);
var t_name varchar2(30);
var c_name varchar2(30);
var suppress_nonpopular_buckets varchar2(1);

exec :u_name := trim(upper('&uname_in'));
exec :t_name := trim(upper('&tname_in'));
exec :c_name := trim(upper('&cname_in'));
exec :suppress_nonpopular_buckets := upper('&suppress_nonpopular_buckets_in');

col column_name format a30;
col histogram_value format a32;
col owner format a12;
col buckets format a7

select dtc.owner, dtc.table_name, dtc.column_name, dtc.histogram, decode(dtc.histogram, 'FREQUENCY', decode(dtc.num_buckets, 0, '', dtc.num_buckets), 'HEIGHT BALANCED', decode(dtc.num_buckets, 0, '', 1, '', dtc.num_buckets)) as buckets, dt.num_rows
from dba_tab_columns dtc, dba_tables dt
where dtc.table_name = :t_name
      and dtc.column_name = :c_name
      and dtc.owner = :u_name
      and dtc.table_name = dt.table_name
      and dtc.owner = dt.owner;
PROMPT
PROMPT
col est_percent format 999.99 heading "ESTIMATED|PERCENT"
col est_rows like num_rows heading "ESTIMATED|ROWS"
col frequency like num_rows
select histogram_value, frequency, est_percent, est_rows from
(select dic.histogram_value, dic.frequency, decode(dic.frequency, 0, null, 1, null, dic.frequency)/sum(dic.frequency) over ()*100 as est_percent,
       to_number(decode(dic.histogram, 'HEIGHT BALANCED', decode(dic.frequency, 0, null, 1, null, round(dic.num_rows*dic.frequency/sum(dic.frequency) over (), 0)), null)) as est_rows
      ,dic.histogram
from (
select
   (case when dtc.data_type in ('CHAR','VARCHAR','VARCHAR2')
          then dth.endpoint_actual_value
         when dtc.data_type in ('NUMBER','FLOAT')
          then to_char(dth.endpoint_value)
         when dtc.data_type in ('DATE', 'TIMESTAMP(9)')
          then to_char(to_date(trunc(dth.endpoint_value), 'J'), 'MM-DD-YYYY') || ' ' || to_char(to_date(trunc(((dth.endpoint_value - trunc(dth.endpoint_value))*24*60*60)), 'SSSSS'), 'HH24:MI:SS')
         end) as HISTOGRAM_VALUE
    ,endpoint_number - lag(endpoint_number, 1, 0) over (order by endpoint_number) as frequency
    ,dt.num_rows
    ,dtc.histogram
from dba_tab_histograms dth, dba_tab_columns dtc, dba_tables dt
where dth.table_name = :t_name
   and dth.column_name = :c_name
   and dth.owner = :u_name
   and dth.table_name = dtc.table_name
   and dth.column_name = dtc.column_name
   and dth.owner = dtc.owner
   and dth.table_name = dt.table_name
   and dth.owner = dt.owner
ORDER BY dth.endpoint_number
) dic
) x
where :suppress_nonpopular_buckets = 'N'
      or x.histogram = 'FREQUENCY'
      or (:suppress_nonpopular_buckets = 'Y' and x.frequency > 1)
      or x.histogram = 'NONE';
set feedback on
set verify on
